from PyQt6.QtWidgets import QApplication
from qfluentwidgets import PushButton, FluentWindow

app = QApplication([])
w = FluentWindow()
w.resize(600, 400)
btn = PushButton("测试按钮")
w.setCentralWidget(btn)
w.show()
app.exec()
