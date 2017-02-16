//
//  LicenseViewController.swift
//  JPY Rate
//
//  Created by ChenYong-min on 2017/2/16.
//  Copyright © 2017年 Yong Min Chen. All rights reserved.
//

import UIKit

class LicenseViewController: UIViewController {
    @IBOutlet weak var licenseText: UITextView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        do {
            licenseText.text = try String.init(contentsOfFile: (Bundle.main.url(forResource: "LICENSE", withExtension: "")?.relativePath)!, encoding: .utf8)
        } catch {
            licenseText.text = "Error when reading LICENSE."
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
