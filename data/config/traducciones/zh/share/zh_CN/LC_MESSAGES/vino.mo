��    G      T  a   �                          !     1  >   @       N   �  O   �     5     O  '   l     �  '   �     �     �  ,   �  #   '  =   K     �  ?   �  �   �  �   u	  �   2
  �   �
  4  �  "   �     �  +   �  *        D  R   ^     �  )   �  .   �          "     1  3   L  '   �     �  !   �     �     �     �  *     )   =     g  $   �  3   �     �  Q   �  �   N  +   �  )        =  &   X  �          	   $  /   .     ^  	   k  2   u  \   �       *     
   7     B  )   J  A  t     �     �     �     �     �  <   �       K   7  P   �     �     �      �       %   $     J     ]  "   j     �  *   �     �  7   �  ~   (  �   �  n   =  �   �  �   9  !        A  !   H     j     �  S   �     �     �          5     <     I  1   _  +   �     �     �     �     �     �  '        A     Z     v  !   �     �  J   �  |        �     �     �     �  �   �     �  
   �  0   �  
   �  	   �  3   �  G   .  
   v  (   �     �  
   �  "   �     E              2   $      3   ;       =               >           (      6   *   !   @           ?                               <   8                   1   G              5   %   .             F              -   C   '         0   A   )             &           ,           :      B   4      9                        D       
   /   "       	   #   7   +                  * <b>Security</b> <b>Sharing</b> <big><b>Another user is trying to view your desktop.</b></big> A tooltip for this URL A user on another computer is trying to remotely view or control your desktop. A user on the computer '%s' is trying to remotely view or control your desktop. A_sk you for confirmation Activation of %s failed: %s
 Activation of %s failed: Unknown Error
 Address Allow other users to _view your desktop Allowed authentication methods Authentication methods Disallow keyboard/pointer input from clients Do you want to allow them to do so? E-mail address to which the remote desktop URL should be sent Enable remote desktop access Failed to activate remote desktop server: tried too many times
 If true, allows remote access to the desktop via the RFB protocol. Users on remote machines may then connect to the desktop using a vncviewer. If true, remote users accessing the desktop are not allowed access until the user on the host machine approves the connection. Recommended especially when access is not password protected. If true, remote users accessing the desktop are only allowed to view the desktop. Remote user's will not be able to use the mouse or keyboard. If true, remote users accessing the desktop are required to be able support encyrption. It is highly recommended that you use a client which supports encryption unless the intervening network is trusted. Lists the authentication methods with which remote users may access the desktop. There are two possible authentication methods; "vnc" causes the remote user to be prompted for a password (the password is specified by the vnc_password key) before connecting and "none" which allows any remote user to connect. Not starting remote desktop server On Hold Only allow remote users to view the desktop Password required for "vnc" authentication Place all clients on hold Problem registering the remote desktop server with bonobo-activation; exiting ...
 Prompt enabled Prompt the user about connection attempts Prompt the user before completing a connection Question Remote Desktop Remote Desktop Preferences Remote Desktop server already running; exiting ...
 Remote desktop server died, restarting
 Require Encryption Require clients to use encryption Require encryption Screen Send this command by email Set your remote desktop access preferences Some of these preferences are locked down Starting remote desktop server The address pointed to by the widget The authentication methods this server should allow The color of the URL's label The password (base64 encoded) used to authenticate types using the VncAuth method The password which the remote user will be prompted for if the "vnc" authentication method is used. The password specified by the key is base64 encoded. The screen for which to create a VNC server The screen on which to display the prompt The screen to be monitored There was an error displaying help:
%s This key specifies the e-mail address to which the remote desktop URL should be sent if the user clicks on the URL in the Remote Desktop preferences dialog. Tooltip URL color Users can view your desktop using this command: VNC Password View Only When a user tries to view or control your desktop: Your XServer does not support the XTest extension - remote desktop access will be view-only
 _Allow _Allow other users to control your desktop _Password: _Refuse _Require the user to enter this password: Project-Id-Version: vino
Report-Msgid-Bugs-To: 
POT-Creation-Date: 2004-09-29 13:06+0100
PO-Revision-Date: 2004-06-01 16:50+0800
Last-Translator: storm <storm-119@163.com>
Language-Team: zh_CN <i18n-translation@lists.linux.net.cn>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
               * <b>安全</b> <b>共享</b> <big><b>另一个用户正在查看您的桌面。</b></big> 此 URL 的工具提示 在其它计算机上的用户在尝试远程查看或控制您的桌面。 在计算机“%s”上的用户正在尝试远程查看或控制您的桌面。 请您确认(_S) 启动 %s 失败：%s
 激活 %s 失败：未知错误
 地址 允许其他人查看您的桌面(_V) 允许验证方法 验证方法 禁止客户端键盘/指针输入 您允许他们这样做吗？ 发送远程桌面的 URL 的 Email 地址 启用远程桌面访问 启动远程桌面服务器失败：尝试次数太多
 如果为 true，允许由 RFB 协议访问远程桌面。远程机器的的用户然后可以使用 vncviewer 连接桌面。 如果为 true，直到主机的用户批准了连接，远程用户才可以访问远程桌面。特别推荐使用于没有密码保护的访问。 如果为 true，远程用户访问桌面时只允许查看桌面。远程用户不能使用鼠标与键盘。 如果为 true，远程用户访问桌面时要求支持加密。强烈推荐您的客户端支持加密，除非中间网络足够信任。 列出远程用户访问使用的验证方法。有两种可能的验证方法：“vnc”在连接之前提示远程用户输入密码(密码由 vnc_password 键指定)或者“没有密码”，允许任何远程用户连接。 没有启动远程桌面服务器 挂起 仅允许远程用户查看桌面 “VNC”认证的密码 挂起所有客户端 用 bonobo-activation 注册远程桌面服务器时发生问题；正在退出...
 提示启用 提示用户关于连接尝试 完成连接前提示用户 问题 远程桌面 远程桌面首选项 远程桌面服务器已经在运行；退出...
 远程桌面服务器宕机，重新启动
 请求加密 请求客户端使用加密 请求加密 屏幕 用电子邮件发送此命令 设置您的远程桌面访问首选项 某些首选项被锁住 启动远程桌面服务器 窗口部件指出的地址 此服务器允许的验证方法 URL 标签的颜色 用于使用 Vnc 验证方法的验证类型的密码(基于 64 位编码) 远程用户会被提示输入的密码，如果“vnc”验证方法启用。此由键指定密码是基于 64 位编码。 创建 VNC 服务的屏幕 显示提示信息的屏幕 要监视的屏幕 显示帮助时出错：
%s 此键指定远程桌面 URL 应发送到的 E-mail 地址。用户在点击了远程桌面首选项设置对话框的内的 URL 时，会向此地址发送邮件。 工具提示 URL 颜色 用户可以使用此命令查看您的桌面： VNC 密码 仅查看 当一个用户尝试查看或控制您的桌面： 您的 XServer 不支持 XTest 扩展 - 远程桌面访问只能查看
 允许(_A) 允许其他用户控制您的桌面(_A) 密码(_P)： 拒绝(_R) 请求用户输入此密码(_R)： 