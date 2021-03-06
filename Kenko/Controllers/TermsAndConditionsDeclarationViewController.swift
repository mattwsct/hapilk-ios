//
//  TermsAndConditionsDeclarationViewController.swift
//  Kenko
//
//  Created by David Garcia Tort on 9/10/19.
//  Copyright © 2019 Innovatech Studio Co., LTD. All rights reserved.
//

import UIKit

class TermsAndConditionsDeclarationViewController: UIViewController {
    
    @IBOutlet weak var termsAndConditionsDeclarationTextView: UITextView! {
        didSet {
            termsAndConditionsDeclarationTextView.contentInset = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
            termsAndConditionsDeclarationTextView.delegate = self
        }
    }
    
    private let termsAndConditionsDeclarationText = """
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
        <h1>アプリ利用規約</h1>
        <p>センコーグループホールディングス株式会社（以下「当社」）は、当社が提供するアプリケーションソフト 「はぴるく」（以下「本アプリ」 ）に関するサービス（以下「本サービス」 ）のご利用規約（以下「本規約」 ）を以下の通り定めます。</p>
        ​<br>
        <h2>第１条 利用者</h2>
        <ol>
            <li>本規約は、本サービスの提供を希望して本アプリを自己の端末にダウンロードした利用者（以下「利用者」）に適用されます。</li>
            <li>利用者は、本アプリを自己の端末にダウンロードし、本サービスを利用することにより、本規約に同意したものとみなされます。</li>
            <li>本アプリのダウンロード、及び本サービスの利用にかかる通信費用は、利用者が負担するものとします。</li>
        </ol>
        ​​<br>
        <h2>第２条 利用者情報</h2>
        <ol>
            <li>当社は、本サービスの提供のため、本アプリをご利用になる皆様の利便性を向上させるため、端末名、OS、本アプリの識別ID及び連携アプリ情報（Google Fit や ヘルスケアなどが持つ健康増進に関する情報）（以下、総称して「利用者情報」といいます。なお、利用者情報には、氏名、メールアドレス、クレジットカード情報などの情報を含みません。）を取得することがあります。</li>
            <li>利用者が、スマートフォンアプリ内の設定画面で「位置情報による通知」によりオプトアウト設定を行った場合、当社はSP取得情報（利用者情報のうち、スマートフォンから取得する情報、すなわちアクセスログを除く情報をいう。）を取得しません。</li>
            <li>当社は、利用者情報を原則として第三者に開示する事はありませんが、以下の場合には第三者に利用者情報を提供することがあります。ただし、提供する利用者情報は必要最低限の情報に限り、利用者情報が漏えい、滅失、改ざんされないように図ります。</li>
            <ol type="a">
                <li>本サービスの提供、マーケティング、新規サービス開発、及びサービス向上に関する業務を第三者に委託する場合</li>
                <li>公的機関から正当な理由により開示を要求された場合</li>
                <li>その他任意に利用者の同意を得た場合</li>
            </ol>
            <li>当社は、本アプリを通じて取得した利用者情報及び利用者の個人情報を「個人情報保護方針」に基づき適切に取り扱います。</li>
            <li><a href="http://www.senkogrouphd.co.jp/privacy/index.html">個人情報保護方針</a></li>
        </ol>
        ​​<br>
        <h2>第３条 本アプリの権利</h2>
        <ol>
            <li>本アプリ中の表示、及び本アプリを構成するプログラム等に係る著作権、商標権等すべての知的財産権は、当社またはコンテンツ提供者に帰属します。</li>
            <li>本アプリは、利用者本人が個人として使用する目的でのみ利用することができるものとし、すべてのコンテンツの無断転載をお断りいたします。</li>
            <li>前項の規定に違反して著作権等の知的財産権に関する問題が生じた場合、利用者は自己の費用と責任において、その問題を解決するとともに、当社に対して何らの迷惑又は損害等を与えてはなりません。</li>
        </ol>
        ​​<br>
        <h2>第４条 禁止行為</h2>
        <ol>
            <li>利用者は次の各号に該当する行為を行ってはならず、利用者が次の各号に該当する行為を行った場合、当社は、利用者に事前通知することなく本サービスの提供を停止します。</li>
            <ol type="a">
                <li>本アプリを複製、修正、変更、改変、または翻案する行為</li>
                <li>本アプリを構成するプログラム（オブジェクトコード、ソースコード等全てを含みます）を複製し、または第三者に開示する行為</li>
                <li>本サービスの運営を妨げる行為、またはその恐れのある行為</li>
                <li>本アプリの内容を本サービス利用以外の目的に使用する行為</li>
                <li>他の利用者、第三者もしくは当社に損害、不利益を与える行為、またはその恐れのある行為</li>
                <li>公序良俗に反する行為、法令に違反する行為、またはその恐れのある行為</li>
                <li>本規約に違反する行為</li>
                <li>その他、当社が不適当と判断する行為</li>
            </ol>
            <li>利用者の前項各号に該当する行為により、他の利用者、第三者もしくは当社に損害が生じた場合、当社は利用者の利用資格の停止または抹消とともに当該損害の賠償を請求することがあります。</li>
            <li>当社が前項に基づき利用資格の停止または抹消をしたことにより、利用者が本サービスを利用できなくなり、これにより当該利用者または第三者に損害が発生したとしても、当社は一切の責任を負いません。また、利用資格の喪失後も当該利用者は、全ての法的責任を負わなければなりません。</li>
        </ol>
        ​​<br>
        <h2>第５条 免責</h2>
        <ol>
            <li>当社は、以下の事項に関し、その一切の責任を問いません。</li>
            <ol type="a">
                <li>利用者が本サービスを利用することにより、他の利用者または第三者に対して損害を与えた場合</li>
                <li>利用者が本サービスを利用できなかった場合、または本サービスの利用に関し、当社に責のない事由により損害を被った場合</li>
            </ol>
            <li>当社は、本アプリがすべての利用者の端末に対応することを保証しません。</li>
            <ol type="a">
                <li>推奨のOSのバージョンであっても、端末によりアプリが正常に動作しない場合があります。</li>
                <li>本アプリはスマートフォン用アプリとして開発しており、タブレットでの動作保証はありません。</li>
                <li>本アプリは日本国内からのみご利用いただけます。国外からの通信およびVPN等による海外経由の通信の場合、ご利用いただけません。</li>
            </ol>
            <li>当社は、本サービスの内容および利用者が本アプリを通じて知り得る情報について、その完全性、正確性、確実性、有用性等に関して、いかなる責任も負いません。</li>
            <li>本アプリに掲載されている情報、画像およびリンク等を利用することにより、利用者の機器等に損害が生じた場合、また、ウィルス感染した場合等について、当社はいかなる責任も負いません。</li>
            <li>本アプリに掲載されている商品情報については正確性を期しておりますが、保証をするものではありません。</li>
            <li>当社は、本アプリ利用に際して入力されたユーザIDおよびパスワード等が、当社にて登録されたものと一致することを確認した場合、当社会員による利用があったものとみなし、それらが盗用、不正使用その他の事情により会員以外の者が使用している場合であっても、それにより生じた損害については、当社は一切責任を負いません。ユーザIDおよびパスワードは、他人に知られることが無い様に定期的に変更する等、お客様ご自身にて責任をもって管理されますようお願いいたします。</li>
        </ol>
        ​​<br>
        <h2>第６条 その他</h2>
        <ol>
            <li>当社は、利用者の事前の承諾を得ることなく、本アプリ及び本サービスの内容の全部または一部を変更することがあります。</li>
            <li>当社は、利用者の事前の承諾を得ることなく本規約を変更することがあります。なお、変更後の本規約は、変更時に効力を生じます。</li>
            <li>当社が提供する他のアプリケーションソフトのサービスに関し別途使用条件等を提示したときに、当該使用条件等の規定が本規約と矛盾する場合には、当該使用条件等の規定が優先して適用されます。</li>
            <li>本サービスを利用するにあたって、本規約等以外に、対応端末の製造者や通信会社等の第三者が提供するサービスを併せて使用する場合には、当該第三者の規約等が適用される場合があります。</li>
        </ol>
        ​​<br>
        <h2>第７条 専属的合意管轄裁判所</h2>
        <ol>
            <li>本規約の解釈は日本法を準拠法とするものとします。</li>
            <li>本規約または本サービスの利用に際して、当社と利用者の間に紛争が生じた場合、東京地方裁判所を第一審の専属的合意管轄裁判所とします。</li>
        </ol>
        ​​<br>
        <p align="right" >以　上</p>
    </body>
    </html>
    """.HTMLToAttributedString

    override func viewDidLoad() {
        super.viewDidLoad()

        termsAndConditionsDeclarationTextView.attributedText = termsAndConditionsDeclarationText
    }
}

extension TermsAndConditionsDeclarationViewController: UITextViewDelegate {
    
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        UIApplication.shared.open(URL, options: [:], completionHandler: nil)
        return false
    }
    
}
