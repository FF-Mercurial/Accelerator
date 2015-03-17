# Notes for Accelerator

- 总体架构(双进程)
    - Node-Webkit前端
        - setInterval定时刷新界面(从后端获取数据)
    - Ruby后端
        - 主线程不断读取来自前端的输入, 并作出响应(IO与process串行, process会阻塞IO)
    - 前后端通过进程管道通信, 使用json协议

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
        - 功能: 维护一个flag, myKill -> flag = true, myKilled -> return flag, 以myKilled设置断点, 以便调用myKill来安全地, 异步地中断线程(主要是用于DownloadThread, 考虑到直接中断线程可能会导致@part写不完全), 使用ConditionVariable使myKill变为同步方法(经过断点时signal, 确保线程任务已经结束)
        - 问题: conditionVariable.wait可能产生deadlock(wait后无signal), 难以确保调用myKill时线程还有机会经过断点(myKilled)
        - 解决方案: 
    - 文件IO
        - 各种IO modes
            - r/r+: 文件必须存在
            - w/w+: 若文件存在则先清空
            - a/a+: 若文件存在则一切写入内容从原文件末尾开始(append)
        - 修改已存在的文件用r+
    - json传输二进制数据
        - json是字符编码(UTF-8), 而UTF-8字符串是字节串的真子集(字节串按UTF-8解析可能遇到非法UTF-8字符), 所以不能直接用json编码二进制数据
        - 字节串的一种字符表示形式: ASCII-8字符串, 但ASCII-8并不是UTF-8的子集, 因此也不能用于json编码中
        - 从ASCII-8中得到启发, 考虑ASCII-7, 它是UTF-8的子集, 可以直接用json编码, 而且可以很方便地与ASCII-8(字节串的字符表示形式)进行转换, 比如最简单的, 用两个ASCII-7字符(2个字节)表示一个ASCII-8字符(也就是一个字节), 其中高字节取最高位, 低字节取低7位(11111111 => 00000001 01111111), 完成转换, 空间效率为50%, 不大可观, 但由于瓶颈在远端网络IO, 而程序中这种转换只存在于局域网内的通信, 所以可以忽略空间效率的问题
        - 结论: 二进制数据可以通过ASCII-7编码成为合法的UTF-8串, 再用json进行编码, 空间效率50%
