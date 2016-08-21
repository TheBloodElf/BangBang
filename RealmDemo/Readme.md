                               即将做
添加任务完成情况（需要服务器修改数据表)
                                bug
任务同步偶尔出现不是对象存进数据库的情况
                               解决日志
签到全是上班。。数据也是一样                    需要对对象进行深拷贝
签到地址存入数据库全部一样                      主键一样，冲突了
退出圈子后圈子数组不更新                        先删除再添加就会触发回调
文件下载下来存不了本地                         本地文件夹没有创建
导航栏显示混乱                                统一用self.navigationController隐藏和显          示导航栏
讨论组设置中保存到通讯录/取消保存 连续操作会崩溃   直接用数据库读出来的对象进行添加和删除

                               第三方库
BMDeviceActivityManager             检测屏幕亮起和熄灭的库
IFLY                                讯飞语音

                              有用的技术点
iOS给Core Image增加了两种人脸检测功能：CIDetectorEyeBlink以及CIDetectorSmile
UIScreenEdgePanGestureRecognizer 继承自UIPanGestureRecognizer ，它可以让你从屏幕边界即可检测手势
我们现在可以使用 UIDocumentPickerViewController 来从第三方存储 (以及第三方 app 通过应用扩展所实现的存储) 中选取文件。
动态监测内存泄漏MLeaksFinder
离屏渲染如有问题，用UIImageView+CornerRadius解决
