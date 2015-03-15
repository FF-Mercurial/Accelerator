# Notes for Accelerator

- 总体架构(双进程)
    - Node-Webkit前端
        - setInterval定时刷新界面(从后端获取数据)
    - Ruby后端
        - 主线程不断读取来自前端的输入, 并作出响应(IO与process串行, process会阻塞IO)
    前后端通过进程管道通信

- 通信规则
    - 前端与后端
        - -> new , url, path
        - -> start/suspend/delete, id
        - -> fetchInfo
        - -> exit
        - <- info
        - <- exit
    - Master与Supporter
        - -> new, id, url
        - -> delete, id
        - -> part, id
        - <- nextPart, id
        - <- chunk, id, part, chunk

- Master与Supporters之间的同步方式
    - new task -> push to Supporters
    - Supporter joined -> push tasks
    - delete/suspend/finish task -> notify Supporters to delete

- 遇到的问题
    - conditionVariable.wait可能产生deadlock(wait后无signal)
    - 各种IO模式
        - r/r+: 文件必须存在
        - w/w+: 若文件存在则先清空
        - a/a+: 若文件存在则一切写入内容从原文件末尾开始(append)

- 未处理的问题
    - LocalThread中使用了thread.kill(暴力终止线程?), 可能是危险的做法
