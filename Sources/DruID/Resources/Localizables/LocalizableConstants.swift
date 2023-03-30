/*
LocalizableConstants.swift

GENERATED - DO NOT MODIFY - use localio instead.

Created by localio
*/

import Foundation

private class CurrentBundleFinder {}

extension Foundation.Bundle {
    static var package: Bundle {
        final class CurrentBundleFinder {}

        let packageName = "DruID"
        let targetName = "DruID"
        let bundleName = "\(packageName)_\(targetName)"
        let candidates = [
            /* Bundle should be present here when the package is linked into an App. */
            Bundle.main.resourceURL,

            /* Bundle should be present here when the package is linked into a framework. */
            Bundle(for: CurrentBundleFinder.self).resourceURL,

            /* For command-line tools. */
            Bundle.main.bundleURL,

            /* Bundle should be present here when running previews from a different package (this is the path to "…/Debug-iphonesimulator/"). */
            Bundle(for: CurrentBundleFinder.self).resourceURL?.deletingLastPathComponent().deletingLastPathComponent()
        ]

        for candidate in candidates {
            let bundlePath = candidate?.appendingPathComponent(bundleName + ".bundle")
            if let bundle = bundlePath.flatMap(Bundle.init(url:)) {
                return bundle
            }
        }
        fatalError("unable to find bundle named \(bundleName)")
    }
}

private extension String {
    var localized: String {
        NSLocalizedString(self, tableName: nil, bundle: Bundle.package, value: "", comment: "")
    }
}

enum Strings {
    static let common_language_code: String = "common_language_code".localized
    static let common_cancel_text: String = "common_cancel_text".localized
    static let common_close_text: String = "common_close_text".localized
    static let common_accept_text: String = "common_accept_text".localized
    static let common_done_text: String = "common_done_text".localized
    static let common_back_text: String = "common_back_text".localized
    static let common_continue_text: String = "common_continue_text".localized
    static let common_save_text: String = "common_save_text".localized
    static let common_edit_text: String = "common_edit_text".localized
    static let common_yes_text: String = "common_yes_text".localized
    static let common_no_text: String = "common_no_text".localized
    static let common_error_text: String = "common_error_text".localized
    static let common_unknown_error_text: String = "common_unknown_error_text".localized
    static let common_loading_text: String = "common_loading_text".localized
    static let common_mandatory_text: String = "common_mandatory_text".localized
    static let common_facebook_button: String = "common_facebook_button".localized
    static let common_apple_button: String = "common_apple_button".localized
    static let common_accept_all_switch: String = "common_accept_all_switch".localized
    static let common_invalid_email_text: String = "common_invalid_email_text".localized
    static let login_username_title: String = "login_username_title".localized
    static let login_username_placeholder: String = "login_username_placeholder".localized
    static let login_password_title: String = "login_password_title".localized
    static let login_password_placeholder: String = "login_password_placeholder".localized
    static let login_forgot_password_button: String = "login_forgot_password_button".localized
    static let login_login_button: String = "login_login_button".localized
    static let login_not_account_yet_text: String = "login_not_account_yet_text".localized
    static let login_register_button: String = "login_register_button".localized
    static let link_account_header_text: String = "link_account_header_text".localized
    static let link_account_password_title: String = "link_account_password_title".localized
    static let link_account_password_placeholder: String = "link_account_password_placeholder".localized
    static let link_account_sync_button: String = "link_account_sync_button".localized
    static let register_title_text: String = "register_title_text".localized
    static let register_header_text: String = "register_header_text".localized
    static let register_send_button: String = "register_send_button".localized
    static let register_validation_error_text: String = "register_validation_error_text".localized
    static let register_optional_text: String = "register_optional_text".localized
    static let register_confirmation_title_text: String = "register_confirmation_title_text".localized
    static let register_confirmation_message_text: String = "register_confirmation_message_text".localized
    static let register_confirmation_success_but_email_not_sent_text: String = "register_confirmation_success_but_email_not_sent_text".localized
    static let register_confirmation_sucess_already_confirmed_text: String = "register_confirmation_sucess_already_confirmed_text".localized
    static let register_confirmation_accept_button: String = "register_confirmation_accept_button".localized
    static let register_terms_only_send_button: String = "register_terms_only_send_button".localized
    static let reset_password_header_text: String = "reset_password_header_text".localized
    static let reset_password_email_title: String = "reset_password_email_title".localized
    static let reset_password_email_placeholder: String = "reset_password_email_placeholder".localized
    static let reset_password_send_button: String = "reset_password_send_button".localized
    static let reset_password_success_text: String = "reset_password_success_text".localized
}
