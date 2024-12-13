import Firebase
import CodableFirebase

enum ReferralError: Error { case notFound, decode }

class ReferralManager {
  static let referrals_ref = Database.database().reference().child("referrals")
  
  static func isCodeValid(referral_code: String) async throws -> Bool {
    return try await withCheckedThrowingContinuation { continuation in
      Task{
        do
        {
          try await getReferral(referral_code: referral_code)
          continuation.resume(returning: true)
        }
        catch
        {
          continuation.resume(returning: false)
        }
      }
    }
  }
  
  @discardableResult
  static func getReferral(referral_code: String) async throws -> AuxrReferral {
    return try await withCheckedThrowingContinuation { continuation in
      let query = self.referrals_ref.queryOrdered(byChild: "code").queryEqual(toValue: referral_code)
      Task{
        let snapshot = await query.observeSingleEventAndPreviousSiblingKey(of: .value)
        if !snapshot.0.exists(){ return continuation.resume(throwing: ReferralError.notFound) }
        if let referral = snapshot.0.value{
          do
          {
            let referral_tpl = try FirebaseDecoder().decode([String: AuxrReferral].self, from: referral)
            if let ref = referral_tpl.first{
              continuation.resume(returning: ref.value)
            }
            else{
              continuation.resume(throwing: ReferralError.decode)
            }
          }
          catch let error
          {
            print(error)
            continuation.resume(throwing: ReferralError.decode)
          }
        }
        else{
          continuation.resume(throwing: ReferralError.notFound)
        }
      }
    }
  }
  
  static func incrementReferral(referral_code: String, current_user: User) async throws {
    if let acct = current_user.Account {
      let referral = try await getReferral(referral_code: referral_code)
      let ref = self.referrals_ref.child(referral.ID)
      var attempts = 0
      ref.runTransactionBlock({ (currentData: MutableData) -> TransactionResult in
        // Retrieve the current data at the reference node
        attempts += 1
        guard let data = currentData.value as? [String: Any] else{
          return attempts >= 2 ? .abort() : .success(withValue: currentData)
        }
        do
        {
          let db_referral = try FirebaseDecoder().decode(AuxrReferral.self, from: data)
          guard !db_referral.referred_tokens.contains(current_user.device_id) else{
            return .abort()
          }
          db_referral.num_referrals += 1
          db_referral.referred_tokens.append(current_user.device_id)
          db_referral.referred_usernames.append(acct.Username)
          // Set the modified data to be saved
          currentData.value = try FirebaseEncoder().encode(db_referral)
          // Return success to commit the transaction
          return .success(withValue: currentData)
        }
        catch
        {
          return .abort()
        }
      }){ (error, committed, snapshot) in
        if let error = error {
          // Handle any errors
          print("Transaction failed with error: \(error.localizedDescription)")
        }
        else if committed {
          // Handle successful transaction
          print("Transaction committed with snapshot: \(String(describing: snapshot))")
        }
        else{
          // Transaction aborted
          print("Transaction aborted")
        }
      }
    }
  }
}
