require('UIColor,REFrostedViewController,MainBusinessController,LeftMenuController,UINavigationController');
//业务控制器
defineClass('BusinessController', {
            viewDidLoad: function() {
            self.super().viewDidLoad();
            self.view().setBackgroundColor(UIColor.whiteColor());
            //创建界面
            var _rEFrostedView = REFrostedViewController.alloc().initWithContentViewController_menuViewController(MainBusinessController.new(), LeftMenuController.new());
            _rEFrostedView.setLiveBlur(YES);
            //这个导航用于弹出通知信息，是业务模块的根控制器
            var businessNav = UINavigationController.alloc().initWithRootViewController(_rEFrostedView);
            self.addChildViewController(businessNav);
            businessNav.view().willMoveToSuperview(self.view());
            businessNav.willMoveToParentViewController(self);
            businessNav.setNavigationBarHidden_animated(YES, YES);
            businessNav.navigationBar().setTranslucent(NO);
            businessNav.navigationBar().setBarTintColor(UIColor.colorWithRed_green_blue_alpha(8 / 255, 21 / 255, 63 / 255, 1));
            self.view().addSubview(businessNav.view());
        },
});