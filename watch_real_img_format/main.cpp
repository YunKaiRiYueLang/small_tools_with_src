/**
 * image_format_detector.cpp
 * 读取图片文件，检测真实格式（不依赖文件后缀）
 * 编译: g++ -O2 -o image_format_detector image_format_detector.cpp
 */

#include <iostream>
#include <fstream>
#include <string>
#include <vector>
#include <cstdint>
#include <map>
#include <iomanip>
#include<sstream>
#include<algorithm>

struct ImageFormat {
    std::string name;
    std::string mime;
    std::string description;
    std::vector<uint8_t> magic;      // 魔数字节
    size_t offset;                     // 魔数偏移（通常是0）
};

static const std::vector<ImageFormat> FORMATS = {
    // JPEG - FF D8
    {"JPEG",      "image/jpeg",      "JPEG Image (SOI marker)", {0xFF, 0xD8}, 0},

    // PNG - 89 50 4E 47
    {"PNG",       "image/png",       "Portable Network Graphics", {0x89, 0x50, 0x4E, 0x47}, 0},

    // GIF87a
    {"GIF",       "image/gif",       "Graphics Interchange Format", {0x47, 0x49, 0x46, 0x38, 0x37, 0x61}, 0},

    // GIF89a
    {"GIF",       "image/gif",       "Graphics Interchange Format", {0x47, 0x49, 0x46, 0x38, 0x39, 0x61}, 0},

    // BMP - 42 4D
    {"BMP",       "image/bmp",       "Bitmap Image", {0x42, 0x4D}, 0},

    // TIFF (little endian) - 49 49 2A 00
    {"TIFF",      "image/tiff",      "Tagged Image File Format (little-endian)", {0x49, 0x49, 0x2A, 0x00}, 0},

    // TIFF (big endian) - 4D 4D 00 2A
    {"TIFF",      "image/tiff",      "Tagged Image File Format (big-endian)", {0x4D, 0x4D, 0x00, 0x2A}, 0},

    // WebP - RIFF .... WEBP
    {"WebP",      "image/webp",      "WebP Image", {0x52, 0x49, 0x46, 0x46}, 0},

    // PDF - 25 50 44 46
    {"PDF",       "application/pdf", "PDF Document (often mislabeled as image)", {0x25, 0x50, 0x44, 0x46}, 0},

    // TIFF with BigTiff marker (64-bit TIFF)
    {"BigTIFF",   "image/tiff",      "BigTIFF (64-bit TIFF)", {0x00, 0x00, 0x49, 0x49, 0x2B, 0x00}, 0},
};

std::string bytesToHex(const std::vector<uint8_t>& bytes, size_t offset, size_t count) {
    std::ostringstream oss;
    for (size_t i = offset; i < offset + count && i < bytes.size(); ++i) {
        oss << std::hex << std::uppercase << std::setfill('0') << std::setw(2)
            << static_cast<int>(bytes[i]) << " ";
    }
    return oss.str();
}

std::map<std::string, std::string> detectFormat(const std::string& filepath) {
    std::map<std::string, std::string> result;

    std::ifstream file(filepath, std::ios::binary);
    if (!file.is_open()) {
        result["status"] = "ERROR";
        result["message"] = "Cannot open file: " + filepath;
        return result;
    }

    // 读取文件头部（最多 64 字节）
    std::vector<uint8_t> header(64);
    file.read(reinterpret_cast<char*>(header.data()), 64);
    size_t bytesRead = file.gcount();
    file.close();

    result["status"] = "OK";
    result["file_size_bytes"] = std::to_string(bytesRead);
    result["header_hex"] = bytesToHex(header, 0, std::min(bytesRead, (size_t)16));

    bool detected = false;

    // 检测 WebP (RIFF....WEBP，需要特殊处理)
    if (bytesRead >= 12 &&
        header[0] == 0x52 && header[1] == 0x49 && header[2] == 0x46 && header[3] == 0x46 &&  // RIFF
        header[8] == 0x57 && header[9] == 0x45 && header[10] == 0x42 && header[11] == 0x50)   // WEBP
    {
        // 检查具体子类型
        if (bytesRead >= 16 && header[12] == 0x56 && header[13] == 0x50 && header[14] == 0x38 && header[15] == 0x20) {
            result["format"] = "WebP";
            result["subtype"] = "VP8 Lossy (lossy)";
        }
        else if (bytesRead >= 16 && header[12] == 0x56 && header[13] == 0x50 && header[14] == 0x38 && header[15] == 0x4C) {
            result["format"] = "WebP";
            result["subtype"] = "VP8L (lossless)";
        }
        else if (bytesRead >= 16 && header[12] == 0x45 && header[13] == 0x58 && header[14] == 0x54 && header[15] == 0x4D) {
            result["format"] = "WebP";
            result["subtype"] = "VP8X (extended)";
        }
        else {
            result["format"] = "WebP (RIFF container)";
        }
        result["mime"] = "image/webp";
        result["match_type"] = "RIFF header + WEBP marker at offset 8";
        result["confidence"] = "HIGH";
        detected = true;
    }

    // 检测 BigTIFF (00 00 49 49 2B 00)
    if (!detected && bytesRead >= 6 &&
        header[0] == 0x00 && header[1] == 0x00 &&
        header[2] == 0x49 && header[3] == 0x49 &&
        header[4] == 0x2B && header[5] == 0x00) {
        result["format"] = "BigTIFF";
        result["mime"] = "image/tiff";
        result["match_type"] = "BigTIFF magic (offset 0)";
        result["confidence"] = "HIGH";
        result["description"] = "64-bit TIFF (BigTIFF)";
        detected = true;
    }

    // 通用格式检测
    if (!detected) {
        for (const auto& fmt : FORMATS) {
            if (fmt.name == "BigTIFF") continue; // 已单独处理

            if (bytesRead > fmt.offset + fmt.magic.size()) {
                bool match = true;
                for (size_t i = 0; i < fmt.magic.size(); ++i) {
                    if (header[fmt.offset + i] != fmt.magic[i]) {
                        match = false;
                        break;
                    }
                }

                if (match) {
                    result["format"] = fmt.name;
                    result["mime"] = fmt.mime;
                    result["description"] = fmt.description;
                    result["match_type"] = "Magic bytes at offset " + std::to_string(fmt.offset);
                    result["confidence"] = "HIGH";
                    result["magic_bytes"] = bytesToHex(fmt.magic, 0, fmt.magic.size());
                    detected = true;

                    // JPEG 子类型检测
                    if (fmt.name == "JPEG") {
                        if (bytesRead >= 3 && header[2] == 0xE0) {
                            result["subtype"] = "JFIF";
                        }
                        else if (bytesRead >= 3 && header[2] == 0xE1) {
                            result["subtype"] = "Exif";
                        }
                        else {
                            result["subtype"] = "Standard JPEG";
                        }
                    }

                    // TIFF 字节序检测
                    if (fmt.name == "TIFF") {
                        result["endianness"] = (header[0] == 0x49) ? "little-endian (II)" : "big-endian (MM)";
                    }
                    break;
                }
            }
        }
    }

    // 未知格式
    if (!detected) {
        result["format"] = "UNKNOWN";
        result["mime"] = "application/octet-stream";
        result["description"] = "Cannot determine image format from header";
        result["confidence"] = "NONE";
        result["suggestion"] = "File may be corrupted, compressed, or use a non-standard format";
    }

    return result;
}

void printResult(const std::string& filepath, const std::map<std::string, std::string>& res) {
    std::cout << "\n";
    std::cout << "══════════════════════════════════════════════\n";
    std::cout << "  File: " << filepath << "\n";
    std::cout << "══════════════════════════════════════════════\n";

    if (res.at("status") == "ERROR") {
        std::cout << "  [ERROR] " << res.at("message") << "\n";
        return;
    }

    std::cout << "  Format      : " << res.at("format") << "\n";
    std::cout << "  MIME Type   : " << res.at("mime") << "\n";
    std::cout << "  Description : " << res.at("description") << "\n";
    std::cout << "  Confidence  : " << res.at("confidence") << "\n";
    std::cout << "  Match Type  : " << res.at("match_type") << "\n";

    if (res.count("magic_bytes")) {
        std::cout << "  Magic Bytes : " << res.at("magic_bytes") << "\n";
    }

    if (res.count("endianness")) {
        std::cout << "  Endianness  : " << res.at("endianness") << "\n";
    }

    if (res.count("subtype")) {
        std::cout << "  Subtype     : " << res.at("subtype") << "\n";
    }

    std::cout << "  Header (hex): " << res.at("header_hex") << "\n";
    std::cout << "  File Size   : " << res.at("file_size_bytes") << " bytes\n";

    if (res.count("suggestion")) {
        std::cout << "  Suggestion  : " << res.at("suggestion") << "\n";
    }

    std::cout << "──────────────────────────────────────────────\n";

    // 警告：文件名与实际格式不符
    std::string ext = filepath.substr(filepath.find_last_of('.') + 1);
    std::transform(ext.begin(), ext.end(), ext.begin(), ::tolower);

    std::map<std::string, std::string> extToFormat = {
        {"jpg", "JPEG"}, {"jpeg", "JPEG"}, {"png", "PNG"},
        {"gif", "GIF"}, {"bmp", "BMP"}, {"tiff", "TIFF"},
        {"tif", "TIFF"}, {"webp", "WebP"}, {"pdf", "PDF"}
    };

    if (extToFormat.count(ext)) {
        std::string expected = extToFormat[ext];
        std::string actual = res.at("format");

        // WebP 的 RIFF 容器也可能被标为 AVI/WAV 等，需要特殊处理
        std::string ext_lower = ext;
        if (expected != actual) {
            std::cout << "\n  [WARNING] Format mismatch!\n";
            std::cout << "    File extension: ." << ext << " (suggests " << expected << ")\n";
            std::cout << "    Actual format : " << actual << "\n";
            std::cout << "    The file may be mislabeled.\n";
        }
        else {
            std::cout << "\n  [OK] Extension matches actual format.\n";
        }
    }

    std::cout << "\n";
}

void printUsage(const char* progName) {
    std::cout << "\n";
    std::cout << "Usage: " << progName << " <image_file> [image_file2 ...]\n";
    std::cout << "       " << progName << " *.tiff  (wildcard works on Linux/macOS)\n";
    std::cout << "\n";
    std::cout << "Supported formats: JPEG, PNG, GIF, BMP, TIFF (LE/BE), WebP, PDF\n";
    std::cout << "Detects real format by reading file magic bytes, not extension.\n";
    std::cout << "\n";
    std::cout << "Examples:\n";
    std::cout << "  " << progName << " photo.jpg\n";
    std::cout << "  " << progName << " scan_001.tiff scan_002.tiff scan_003.tiff\n";
    std::cout << "  " << progName << " *.tiff 2>/dev/null | grep -i mismatch\n";
    std::cout << "\n";
}

int main(int argc, char* argv[]) {
    std::cout << "Image Format Detector v1.0\n";
    std::cout << "Detects real image format by magic bytes\n";

    if (argc < 2) {
        std::cerr << "\nError: No input file specified.\n";
        printUsage(argv[0]);
        return 1;
    }

    int successCount = 0;
    int mismatchCount = 0;

    for (int i = 1; i < argc; ++i) {
        std::string filepath = argv[i];
        auto result = detectFormat(filepath);

        printResult(filepath, result);

        if (result.at("status") == "OK") {
            successCount++;
            std::string ext = filepath.substr(filepath.find_last_of('.') + 1);
            std::transform(ext.begin(), ext.end(), ext.begin(), ::tolower);

            std::map<std::string, std::string> extToFormat = {
                {"jpg", "JPEG"}, {"jpeg", "JPEG"}, {"png", "PNG"},
                {"gif", "GIF"}, {"bmp", "BMP"}, {"tiff", "TIFF"},
                {"tif", "TIFF"}, {"webp", "WebP"}, {"pdf", "PDF"}
            };

            if (extToFormat.count(ext) && extToFormat[ext] != result.at("format")) {
                mismatchCount++;
            }
        }
    }

    // 汇总
    if (argc > 2) {
        std::cout << "══════════════════════════════════════════════\n";
        std::cout << "  Summary: " << successCount << " files processed";
        if (mismatchCount > 0) {
            std::cout << ", " << mismatchCount << " FORMAT MISMATCH";
        }
        std::cout << "\n";
        std::cout << "══════════════════════════════════════════════\n";
    }

    return 0;
}