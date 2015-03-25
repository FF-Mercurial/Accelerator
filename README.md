# Accelerator

    用Node-Webkit & Ruby混合式前后端构建的桌面下载工具, 主要特色功能是控制多台PC协同下载以达到数倍的速度

    开发进度

        - 后端: 完成基本功能(新建/暂停/删除任务, 自动发现局域网中的其他Accelerator并邀请其加入协同加速), 还在测试当中

        - 前端: 目前仅有约等于命令行的简陋界面 >.< 后端测试完毕后会逐步优化前端界面

    安装手册(暂时不提供完整的软件包, 需要自行下载运行环境)
        
        1. 下载本repo

        2. 下载对应平台的[NodeWebkit](nwjs.io)

        3. 下载/安装对应平台的[Ruby](https://www.ruby-lang.org/en/documentation/installation/)(如果有的话可以跳过), 创建link: Accelerator/Ruby/bin/ruby, 测试版本为2.1.3, 其他版本可能不能正确运行

        4. 启动: 执行/path/to/NodeWebkit/nw /path/to/Accelerator

    使用手册

        目前GUI尚未完善, 只提供命令操作(支持<C-h><C-j>退格和回车哦 >.<), 各命令如下: 

        - new #{url}: 新建任务, 之后会弹出文件对话框提示选择保存路径

        - start/suspend/delete #{taskId}: 开始/暂停/删除指定的任务

        - close: 关闭Supporter模式, 不再为其他Accelerator提供加速

        - open: 开启Supporter模式(默认开启)

        启动后会自动邀请局域网中的其他Accelerators加入协同加速

## notes

- 总体架构(双进程)

    - Node-Webkit前端

        setInterval定时刷新界面(从后端获取数据)

    - Ruby后端

        主线程不断读取来自前端的输入, 并作出响应(IO与process串行, process会阻塞IO)

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

    - 一个错误的实现——可以安全地同步地kill的线程MyThread

        - 实现: 维护一个flag, myKill -> flag = true, myKilled -> return flag, 以myKilled设置断点, 以便调用myKill来安全地, 异步地中断线程(主要是用于DownloadThread, 考虑到直接中断线程可能会导致@part写不完全), 使用ConditionVariable使myKill变为同步方法(经过断点时signal, 线程正式中断后返回)

        - 问题: conditionVariable.wait可能产生deadlock(wait后无signal), 难以确保调用myKill时线程还有机会经过断点(myKilled), 比如此时线程已经执行完毕

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

    - thread.kill的陷阱

        - 心跳线程检测到连接断开时进行异常处理, 其中包括kill心跳线程以及其他操作, 后者不会被执行(因为此前该线程已经被kill)

        - 解决方案: 将thread.kill放到异常处理的最后, 或者新建线程执行异常处理操作

    - 关于跨平台

        - windows和linux的路径分隔符不同('\\', '/'), 应使用path.join生成路径

        - windows平台的stdin没有non-block模式

            - 3种input mode

                - block: 阻塞至完整读取指定长度数据, 不适用于未知长度的数据段

                - partial: 只在完全无数据时阻塞

                - non-block: 完全非阻塞

            - 使用partial read兼容Windows平台
