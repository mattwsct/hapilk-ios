//
//  HealthManagementDeclarationViewController.swift
//  Kenko
//
//  Created by David Garcia Tort on 8/19/19.
//  Copyright © 2019 Innovatech Studio Co., LTD. All rights reserved.
//

import UIKit
import WebKit

class HealthManagementDeclarationViewController: UIViewController {
    
    @IBOutlet weak var healthManagementDeclarationTextView: UITextView! {
        didSet {
            healthManagementDeclarationTextView.contentInset = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        }
    }
    
    private let healthManagementDeclarationText = """
    <html lang="en">
    <head>
        <meta charset="UTF-8">
        <title></title>
        <style>
            body {
                font-family: monospace;
            }
        </style>
    </head>
    <body>
        <h2>センコーグループ健康経営宣言</h2>
        <br/>
        <p>センコーグループは、従業員の健康について次の通り宣言します。</p>
        <ul>
            <li>「人を育て、人々の生活を支援する企業グループ」であり続けること。</li>
            <li>グループ従業員一人ひとりが健康で生き活きと働くことができること。</li>
            <li>そして、人生いつまでも元気で幸せな生活を送ることが、何よりも重要であること。</li>
        </ul>
        <p>この考えのもと、センコーグループは従業員の健康増進に取り組み、「未来潮流を創る企業グループ」として、真に豊かなグローバル社会の実現に貢献します。</p>
        <br/>
        <p align="right">センコーグループホールディングス株式会社<br/>代表取締役社長 福田 泰久</p>
    </body>
    </html>
    """.HTMLToAttributedString
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        healthManagementDeclarationTextView.attributedText = healthManagementDeclarationText
    }

}
