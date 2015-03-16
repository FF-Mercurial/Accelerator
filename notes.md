# Notes for Accelerator

- 总体架构(双进程)
    - Node-Webkit前端
        - setInterval定时刷新界面(从后端获取数据)
    - Ruby后端
        - 主线程不断读取来自前端的输入, 并作出响应(IO与process串行, process会阻塞IO)
    前后端通过进程管道通信, 使用JSON协议

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
    - MyThread
        - 功能: 维护一个flag, myKill -> flag = true, myKilled -> return flag, 以myKilled设置断点, 以便调用myKill来安全地, 异步地中断线程(主要是用于DownloadThread, 考虑到暴力中断线程可能会导致@part写不完全), 使用ConditionVariable使myKill变为同步方法(经过断点时signal, 确保线程任务已经结束)
        - 问题: conditionVariable.wait可能产生deadlock(wait后无signal), 难以确保调用myKill时线程还有机会经过断点(myKilled)
        - 解决方案: thread.kill并不会在临界区中中断线程, 直接使用thread.kill暴力中断, 同时使用Mutex保护敏感数据(@part)
    - 文件IO
        - 各种IO modes
            - r/r+: 文件必须存在
            - w/w+: 若文件存在则先清空
            - a/a+: 若文件存在则一切写入内容从原文件末尾开始(append)
        - 修改已存在的文件用r+
    - json是文本格式, 不能直接用于二进制数据传输
        - 将二进制数据编码为双字节文本(0-127)即可, 但长度会增加
        - str2chunk中使用Enumerator遍历str导致性能大幅下降, 改用Array
