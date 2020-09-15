//
//  RegisterCompanyPVC.swift
//  Ambassadoor Business
//
//  Created by K Saravana Kumar on 15/09/20.
//  Copyright © 2020 Tesseract Freelance, LLC. All rights reserved.
//

import UIKit
protocol PageViewDelegate {
    func pageViewIndexDidChangedelegate(index: Int)
}

protocol PageIndexDelegate {
    func PageIndex(index: Int, viewController: UIViewController)
}

class RegisterCompanyPVC: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate,PageIndexDelegate {
    func PageIndex(index: Int, viewController: UIViewController) {
        self.goToPage(index: index, sender: viewController)
        self.pageViewDidChange?.pageViewIndexDidChangedelegate(index:index)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let i : Int = OrderedVC.lastIndex(of: viewController) else { return nil }
        if i - 1 < 0 {
            return nil
        }
        return OrderedVC[i - 1]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let i : Int = OrderedVC.lastIndex(of: viewController) else { return nil }
        if i + 1 >= OrderedVC.count {
            return nil
        }
        return OrderedVC[i + 1]
    }
    
    //returns a list of all VCs in Home Tab.
    lazy var OrderedVC: [UIViewController] = {
        return [newVC(VC: "referral"), newVC(VC: "companyinfo"), newVC(VC: "website"), newVC(VC: "mission"), newVC(VC: "register")]
    }()
    
    //Allows for returning of VC when string is inputted.
    func newVC(VC: String) -> UIViewController {
        let NewVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: VC)
        self.setDelegateForAllControllers(viewController: NewVC)
        return NewVC
    }
    
    func setDelegateForAllControllers(viewController: UIViewController) {
        
        if let controller = viewController as? ReferralVC {
            controller.pageIdentifyIndexDelegate = self
        }else if let controller = viewController as? ComapanyBasicVC {
            controller.pageIdentifyIndexDelegate = self
        }else if let controller = viewController as? CompanyWebsiteVC{
            controller.pageIdentifyIndexDelegate = self
        }else if let controller = viewController as? CompanyMissionVC{
            controller.pageIdentifyIndexDelegate = self
        }else if let controller = viewController as? RegisterVC{
            controller.dismissDelegate = parentReference
        }
        
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool){
        if (!completed)
        {
          return
        }
        if let index = pageViewController.viewControllers!.first!.view.tag as? Int{
        self.pageViewDidChange?.pageViewIndexDidChangedelegate(index:index)
        }
    }
    
   
    
    //Goes directly to the page specified.
    func goToPage(index: Int, sender: UIViewController) {
        guard let i : Int = OrderedVC.lastIndex(of: sender) else { return }
        if index < OrderedVC.count {
            self.setViewControllers([OrderedVC[index]], direction: index > i ? .forward : .reverse, animated: true, completion: nil)
        }
    }
    
    var pageViewDidChange: PageViewDelegate?
    var parentReference: RegisterCompanyVC?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        dataSource = self
        delegate = self
        
        
        let firstViewController : UIViewController = OrderedVC[0]
        
        
        
        //display that in pages.
        DispatchQueue.main.async {
            self.setViewControllers([firstViewController],
                                    direction: .forward,
                                    animated: true,
                                    completion: nil)
        }
        
        let bgView = UIView(frame: UIScreen.main.bounds)
        bgView.backgroundColor = GetBackColor()
        view.insertSubview(bgView, at: 0)
        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
