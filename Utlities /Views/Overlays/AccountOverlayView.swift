import SwiftUI

enum AccountOverlayType: String, CaseIterable, Identifiable {
  case joinRoom,
       swapHost,
       clearInbox,
       editChannelName,
       deleteChannel,
       removeChannel,
       removeFriend,
       cancelFriendRequest,
       cancelRoomRequest,
       denyFriendRequest,
       denyRoomRequest,
       deleteAccount,
       logout
  var id: Self { self }
}

struct AccountOverlay: View {
  let type: AccountOverlayType
  let TMR = Timer.publish(every: 1, on: .current, in: .common).autoconnect()
  
  @Binding var Show: Bool
  @Binding var Response: Bool
  
  @State private var DisplayTime: Int = 2
  
  var body: some View {
    ZStack(alignment: .center){
      Rectangle()
        .fill(Color("Secondary").opacity(0.75))
        .frame(width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
        .edgesIgnoringSafeArea(.all)
        .zIndex(5)
        .overlay(
          ZStack{
            if(Show){
              switch(type){
              case AccountOverlayType.joinRoom:
                HStack(spacing: 5){
                  Image(systemName: "ipad.and.arrow.forward")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(Color("Tertiary"))
                  Text("Connecting")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(Color("Text"))
                }
                .frame(width: UIScreen.main.bounds.size.width*0.32, height: UIScreen.main.bounds.size.width*0.1, alignment: .center)
                .background(RoundedRectangle(cornerRadius: 3).fill(Color("Primary")))
              case AccountOverlayType.swapHost:
                ZStack{
                  VStack(alignment: .center, spacing: 20){
                    VStack(spacing: 7){
                      Text("HOST CHANGE")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(Color("Text"))
                      Text("Music will play from the new host output device")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(Color("Text"))
                    }
                    HStack(spacing: 20){
                      Button(action: {
                        Response = false
                        Show = false
                      }){
                        Text("NO")
                          .font(.system(size: 12, weight: .bold))
                          .foregroundColor(Color("Tertiary"))
                          .frame(width: UIScreen.main.bounds.size.width*0.15, height: 30)
                          .background(RoundedRectangle(cornerRadius: 3).fill(Color("Secondary")))
                      }
                      Button(action: {
                        Response = true
                        Show = false
                      }){
                        Text("Yes")
                          .font(.system(size: 15, weight: .bold))
                          .foregroundColor(Color("Label"))
                          .frame(width: UIScreen.main.bounds.size.width*0.15, height: 30)
                          .background(RoundedRectangle(cornerRadius: 3).fill(Color("Tertiary")))
                      }
                    }
                  }
                }
                .padding(20)
                .background(RoundedRectangle(cornerRadius: 3).fill(Color("Primary")))
              case AccountOverlayType.editChannelName:
                ZStack{
                  VStack(alignment: .center, spacing: 20){
                    VStack(spacing: 7){
                      Text("Save Changes")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(Color("Tertiary"))
                      Text("Session name will change after save")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(Color("Text"))
                    }
                    HStack(spacing: 20){
                      Button(action: {
                        Response = false
                        Show = false
                      }){
                        Text("NO")
                          .font(.system(size: 12, weight: .bold))
                          .foregroundColor(Color("Tertiary"))
                          .frame(width: UIScreen.main.bounds.size.width*0.15, height: 30)
                          .background(RoundedRectangle(cornerRadius: 3).fill(Color("Secondary")))
                      }
                      Button(action: {
                        Response = true
                        Show = false
                      }){
                        Text("Yes")
                          .font(.system(size: 15, weight: .bold))
                          .foregroundColor(Color("Label"))
                          .frame(width: UIScreen.main.bounds.size.width*0.15, height: 30)
                          .background(RoundedRectangle(cornerRadius: 3).fill(Color("Tertiary")))
                      }
                    }
                  }
                }
                .padding(20)
                .frame(width: UIScreen.main.bounds.size.width*0.78, alignment: .center)
                .background(RoundedRectangle(cornerRadius: 3).fill(Color("Primary")))
              case AccountOverlayType.deleteChannel:
                ZStack{
                  VStack(alignment: .center, spacing: 20){
                    VStack(spacing: 7){
                      Text("Delete Session")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(Color("Red"))
                      Text("Session will no longer be playable")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(Color("Text"))
                    }
                    HStack(spacing: 20){
                      Button(action: {
                        Response = false
                        Show = false
                      }){
                        Text("NO")
                          .font(.system(size: 12, weight: .bold))
                          .foregroundColor(Color("Tertiary"))
                          .frame(width: UIScreen.main.bounds.size.width*0.15, height: 30)
                          .background(RoundedRectangle(cornerRadius: 3).fill(Color("Secondary")))
                      }
                      Button(action: {
                        Response = true
                        Show = false
                      }){
                        Text("Yes")
                          .font(.system(size: 15, weight: .bold))
                          .foregroundColor(Color("Label"))
                          .frame(width: UIScreen.main.bounds.size.width*0.15, height: 30)
                          .background(RoundedRectangle(cornerRadius: 3).fill(Color("Tertiary")))
                      }
                    }
                  }
                }
                .padding(20)
                .frame(width: UIScreen.main.bounds.size.width*0.78, alignment: .center)
                .background(RoundedRectangle(cornerRadius: 3).fill(Color("Primary")))
              case AccountOverlayType.removeChannel:
                ZStack{
                  VStack(alignment: .center, spacing: 20){
                    VStack(spacing: 7){
                      Text("Leave Session")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(Color("Red"))
                      Text("You will no longer be part of this session")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(Color("Text"))
                    }
                    HStack(spacing: 20){
                      Button(action: {
                        Response = false
                        Show = false
                      }){
                        Text("NO")
                          .font(.system(size: 12, weight: .bold))
                          .foregroundColor(Color("Tertiary"))
                          .frame(width: UIScreen.main.bounds.size.width*0.15, height: 30)
                          .background(RoundedRectangle(cornerRadius: 3).fill(Color("Secondary")))
                      }
                      Button(action: {
                        Response = true
                        Show = false
                      }){
                        Text("Yes")
                          .font(.system(size: 15, weight: .bold))
                          .foregroundColor(Color("Label"))
                          .frame(width: UIScreen.main.bounds.size.width*0.15, height: 30)
                          .background(RoundedRectangle(cornerRadius: 3).fill(Color("Tertiary")))
                      }
                    }
                  }
                }
                .padding(20)
                .frame(width: UIScreen.main.bounds.size.width*0.77, alignment: .center)
                .background(RoundedRectangle(cornerRadius: 3).fill(Color("Primary")))
              case AccountOverlayType.removeFriend:
                ZStack{
                  VStack(alignment: .center, spacing: 20){
                    VStack(spacing: 7){
                      Text("Remove Friend")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(Color("Red"))
                      Text("You will no longer be friends with this AUXR")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(Color("Text"))
                    }
                    HStack(spacing: 20){
                      Button(action: {
                        Response = false
                        Show = false
                      }){
                        Text("NO")
                          .font(.system(size: 12, weight: .bold))
                          .foregroundColor(Color("Tertiary"))
                          .frame(width: UIScreen.main.bounds.size.width*0.15, height: 30)
                          .background(RoundedRectangle(cornerRadius: 3).fill(Color("Secondary")))
                      }
                      Button(action: {
                        Response = true
                        Show = false
                      }){
                        Text("Yes")
                          .font(.system(size: 15, weight: .bold))
                          .foregroundColor(Color("Label"))
                          .frame(width: UIScreen.main.bounds.size.width*0.15, height: 30)
                          .background(RoundedRectangle(cornerRadius: 3).fill(Color("Tertiary")))
                      }
                    }
                  }
                }
                .padding(20)
                .frame(width: UIScreen.main.bounds.size.width*0.78, alignment: .center)
                .background(RoundedRectangle(cornerRadius: 3).fill(Color("Primary")))
              case AccountOverlayType.cancelFriendRequest:
                ZStack{
                  VStack(alignment: .center, spacing: 20){
                    VStack(spacing: 7){
                      Text("Cancel Friend Request")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(Color("Red"))
                      Text("Your request will no longer be available")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(Color("Text"))
                    }
                    HStack(spacing: 20){
                      Button(action: {
                        Response = false
                        Show = false
                      }){
                        Text("NO")
                          .font(.system(size: 12, weight: .bold))
                          .foregroundColor(Color("Tertiary"))
                          .frame(width: UIScreen.main.bounds.size.width*0.15, height: 30)
                          .background(RoundedRectangle(cornerRadius: 3).fill(Color("Secondary")))
                      }
                      Button(action: {
                        Response = true
                        Show = false
                      }){
                        Text("Yes")
                          .font(.system(size: 15, weight: .bold))
                          .foregroundColor(Color("Label"))
                          .frame(width: UIScreen.main.bounds.size.width*0.15, height: 30)
                          .background(RoundedRectangle(cornerRadius: 3).fill(Color("Tertiary")))
                      }
                    }
                  }
                }
                .padding(20)
                .frame(width: UIScreen.main.bounds.size.width*0.78, alignment: .center)
                .background(RoundedRectangle(cornerRadius: 3).fill(Color("Primary")))
              case AccountOverlayType.cancelRoomRequest:
                ZStack{
                  VStack(alignment: .center, spacing: 20){
                    VStack(spacing: 7){
                      Text("Cancel Session Invite")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(Color("Red"))
                      Text("Your invite will no longer be available")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(Color("Text"))
                    }
                    HStack(spacing: 20){
                      Button(action: {
                        Response = false
                        Show = false
                      }){
                        Text("NO")
                          .font(.system(size: 12, weight: .bold))
                          .foregroundColor(Color("Tertiary"))
                          .frame(width: UIScreen.main.bounds.size.width*0.15, height: 30)
                          .background(RoundedRectangle(cornerRadius: 3).fill(Color("Secondary")))
                      }
                      Button(action: {
                        Response = true
                        Show = false
                      }){
                        Text("Yes")
                          .font(.system(size: 15, weight: .bold))
                          .foregroundColor(Color("Label"))
                          .frame(width: UIScreen.main.bounds.size.width*0.15, height: 30)
                          .background(RoundedRectangle(cornerRadius: 3).fill(Color("Tertiary")))
                      }
                    }
                  }
                }
                .padding(20)
                .frame(width: UIScreen.main.bounds.size.width*0.78, alignment: .center)
                .background(RoundedRectangle(cornerRadius: 3).fill(Color("Primary")))
              case AccountOverlayType.denyFriendRequest:
                ZStack{
                  VStack(alignment: .center, spacing: 20){
                    VStack(spacing: 7){
                      Text("Deny Friend Request")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(Color("Red"))
                      Text("Friend request will be denied")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(Color("Text"))
                    }
                    HStack(spacing: 20){
                      Button(action: {
                        Response = false
                        Show = false
                      }){
                        Text("NO")
                          .font(.system(size: 12, weight: .bold))
                          .foregroundColor(Color("Tertiary"))
                          .frame(width: UIScreen.main.bounds.size.width*0.15, height: 30)
                          .background(RoundedRectangle(cornerRadius: 3).fill(Color("Secondary")))
                      }
                      Button(action: {
                        Response = true
                        Show = false
                      }){
                        Text("Yes")
                          .font(.system(size: 15, weight: .bold))
                          .foregroundColor(Color("Label"))
                          .frame(width: UIScreen.main.bounds.size.width*0.15, height: 30)
                          .background(RoundedRectangle(cornerRadius: 3).fill(Color("Tertiary")))
                      }
                    }
                  }
                }
                .padding(20)
                .frame(width: UIScreen.main.bounds.size.width*0.78, alignment: .center)
                .background(RoundedRectangle(cornerRadius: 3).fill(Color("Primary")))
              case AccountOverlayType.denyRoomRequest:
                ZStack{
                  VStack(alignment: .center, spacing: 20){
                    VStack(spacing: 7){
                      Text("Deny Session Invite")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(Color("Red"))
                      Text("You will no longer be able to join the session")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(Color("Text"))
                    }
                    HStack(spacing: 20){
                      Button(action: {
                        Response = false
                        Show = false
                      }){
                        Text("NO")
                          .font(.system(size: 12, weight: .bold))
                          .foregroundColor(Color("Tertiary"))
                          .frame(width: UIScreen.main.bounds.size.width*0.15, height: 30)
                          .background(RoundedRectangle(cornerRadius: 3).fill(Color("Secondary")))
                      }
                      Button(action: {
                        Response = true
                        Show = false
                      }){
                        Text("Yes")
                          .font(.system(size: 15, weight: .bold))
                          .foregroundColor(Color("Label"))
                          .frame(width: UIScreen.main.bounds.size.width*0.15, height: 30)
                          .background(RoundedRectangle(cornerRadius: 3).fill(Color("Tertiary")))
                      }
                    }
                  }
                }
                .padding(20)
                .frame(width: UIScreen.main.bounds.size.width*0.78, alignment: .center)
                .background(RoundedRectangle(cornerRadius: 3).fill(Color("Primary")))
              case AccountOverlayType.deleteAccount:
                ZStack{
                  VStack(alignment: .center, spacing: 20){
                    VStack(spacing: 7){
                      Text("Delete Account")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(Color("Red"))
                      Text("Account and all associated data will be deleted, this cannot be undone")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(Color("Text"))
                    }
                    HStack(spacing: 20){
                      Button(action: {
                        Response = false
                        Show = false
                      }){
                        Text("NO")
                          .font(.system(size: 12, weight: .bold))
                          .foregroundColor(Color("Tertiary"))
                          .frame(width: UIScreen.main.bounds.size.width*0.15, height: 30)
                          .background(RoundedRectangle(cornerRadius: 3).fill(Color("Secondary")))
                      }
                      Button(action: {
                        Response = true
                        Show = false
                      }){
                        Text("Yes")
                          .font(.system(size: 15, weight: .bold))
                          .foregroundColor(Color("Label"))
                          .frame(width: UIScreen.main.bounds.size.width*0.15, height: 30)
                          .background(RoundedRectangle(cornerRadius: 3).fill(Color("Tertiary")))
                      }
                    }
                  }
                }
                .padding(20)
                .frame(width: UIScreen.main.bounds.size.width*0.78, alignment: .center)
                .background(RoundedRectangle(cornerRadius: 3).fill(Color("Primary")))
              case AccountOverlayType.clearInbox:
                ZStack{
                  VStack(alignment: .center, spacing: 20){
                    VStack(spacing: 7){
                      Text("Clear Inbox")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(Color("Red"))
                      Text("All notifications will be deleted")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(Color("Text"))
                    }
                    HStack(spacing: 20){
                      Button(action: {
                        Response = false
                        Show = false
                      }){
                        Text("NO")
                          .font(.system(size: 12, weight: .bold))
                          .foregroundColor(Color("Tertiary"))
                          .frame(width: UIScreen.main.bounds.size.width*0.15, height: 30)
                          .background(RoundedRectangle(cornerRadius: 3).fill(Color("Secondary")))
                      }
                      Button(action: {
                        Response = true
                        Show = false
                      }){
                        Text("Yes")
                          .font(.system(size: 15, weight: .bold))
                          .foregroundColor(Color("Label"))
                          .frame(width: UIScreen.main.bounds.size.width*0.15, height: 30)
                          .background(RoundedRectangle(cornerRadius: 3).fill(Color("Tertiary")))
                      }
                    }
                  }
                }
                .padding(20)
                .frame(width: UIScreen.main.bounds.size.width*0.78, alignment: .center)
                .background(RoundedRectangle(cornerRadius: 3).fill(Color("Primary")))
              case AccountOverlayType.logout:
                ZStack{
                  VStack(alignment: .center, spacing: 20){
                    VStack(spacing: 7){
                      Text("Logout")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(Color("Red"))
                      Text("Are you sure you want to log out?")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(Color("Text"))
                    }
                    HStack(spacing: 20){
                      Button(action: {
                        Response = false
                        Show = false
                      }){
                        Text("NO")
                          .font(.system(size: 12, weight: .bold))
                          .foregroundColor(Color("Tertiary"))
                          .frame(width: UIScreen.main.bounds.size.width*0.15, height: 30)
                          .background(RoundedRectangle(cornerRadius: 3).fill(Color("Secondary")))
                      }
                      Button(action: {
                        Response = true
                        Show = false
                      }){
                        Text("Yes")
                          .font(.system(size: 15, weight: .bold))
                          .foregroundColor(Color("Label"))
                          .frame(width: UIScreen.main.bounds.size.width*0.15, height: 30)
                          .background(RoundedRectangle(cornerRadius: 3).fill(Color("Tertiary")))
                      }
                    }
                  }
                }
                .padding(20)
                .frame(width: UIScreen.main.bounds.size.width*0.78, alignment: .center)
                .background(RoundedRectangle(cornerRadius: 3).fill(Color("Primary")))
              }
            }
          }
            .padding(20)
        )
    }
    .padding(20)
    .frame(width: UIScreen.main.bounds.size.width*0.8, height: UIScreen.main.bounds.size.height*0.3, alignment: .center)
    .zIndex(5)
    .onReceive(TMR){ _ in
      if(type == AccountOverlayType.joinRoom){
        if(DisplayTime > 0){ DisplayTime -= 1 }
        else{ Show = false }
      }
    }
  }
}
