import Foundation

extension Result where Success == Void {
    static var empty: Void { () }
}
