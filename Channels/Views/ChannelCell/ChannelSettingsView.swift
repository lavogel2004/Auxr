import SwiftUI
import Combine

struct ChannelSettingsView: View {
  @Environment(\.presentationMode) var Presentation
  @EnvironmentObject var user: User
  @EnvironmentObject var account: AuxrAccount
  
  let RoomID: String
  @Binding var Selected: Bool
  @Binding var NameChange: Bool
  
  @State private var channel: Room? = nil
  @State private var NewRoomName: String = ""
  @State private var ShowOfflineOverlay: Bool = false
  @State private var ShowShareEnabledOverlay: Bool = false
  @State private var ShowBecomeHostEnabledOverlay: Bool = false
  @State private var Deleting: Bool = false
  @State private var Saving: Bool = false
  @State private var SaveResponse: Bool = false
  @State private var DeleteResponse: Bool = false
  @State private var reload: Bool = false
  
  var body: some View {
    ZStack{
      Color("Primary").edgesIgnoringSafeArea(.all)
      if(ShowOfflineOverlay){ OfflineOverlay(networkStatus: NetworkStatus.notConnected, Show: $ShowOfflineOverlay ) }
      if(Saving){ AccountOverlay(type: AccountOverlayType.editChannelName, Show: $Saving, Response: $SaveResponse) }
      else if(SaveResponse){ GeneralOverlay(type: GeneralOverlayType.saved, Show: $SaveResponse) }
      else if(Deleting){ AccountOverlay(type: AccountOverlayType.deleteChannel, Show: $Deleting, Response: $DeleteResponse) }
      else if(ShowShareEnabledOverlay){ GeneralOverlay(type: GeneralOverlayType.enableShare, Show: $ShowShareEnabledOverlay) }
      else if(ShowBecomeHostEnabledOverlay){ GeneralOverlay(type: GeneralOverlayType.enableBeHost, Show: $ShowBecomeHostEnabledOverlay) }
      
      HStack(alignment: .top){
        Button(action: {
          if let rm: Room = channel{ FirebaseManager.RemoveObservers(Room: rm) }
          Presentation.wrappedValue.dismiss()
        }){
          Image(systemName: "chevron.left")
            .font(.system(size: 20, weight: .medium))
            .foregroundColor(Color("Tertiary"))
            .frame(width: UIScreen.main.bounds.size.width*0.2, alignment: .leading)
            .padding(.leading, 10)
        }
      }
      .frame(width: UIScreen.main.bounds.size.width*0.95, alignment: .topLeading)
      .offset(y: -UIScreen.main.bounds.size.height/2*0.85)

      ZStack{
        HStack(spacing: 4){
          Image(systemName: "gearshape.fill")
            .font(.system(size: 20, weight: .bold))
            .foregroundColor(Color("Text"))
          Text("Session Settings")
            .font(.system(size: 20, weight: .bold))
            .foregroundColor(Color("Text"))
        }
      }
      .frame(width: UIScreen.main.bounds.size.width*0.9, alignment: .trailing)
      .offset(y: -UIScreen.main.bounds.size.height/2*0.8)
      .zIndex(2)
      
      VStack(spacing: UIScreen.main.bounds.size.width*0.1){
        ZStack{
          HStack{
            VStack(alignment: .leading){
              TextField("Session Name", text: $NewRoomName)
                .font(.system(size: 16))
                .foregroundColor(Color("Text"))
                .frame(width: UIScreen.main.bounds.size.width*0.7, height: 35)
                .disableAutocorrection(true)
                .onReceive(Just(NewRoomName)){ newRoomNameInput in
                  if(newRoomNameInput.count > 20){ NewRoomName.removeLast() }
                }
              VStack(alignment: .leading, spacing: 5){
                Divider()
                  .frame(width: UIScreen.main.bounds.size.width*0.65, height: 1)
                  .background(Color("Tertiary"))
                  .offset(y: -15)
                Text("Session Name")
                  .font(.system(size: 11, weight: .bold))
                  .foregroundColor(Color("Text"))
                  .offset(x: 2, y: -15)
              }
            }
            .frame(width: UIScreen.main.bounds.size.width*0.65, alignment: .leading)
            .padding(.leading, 5)
            ZStack{
              Button(action: {
                UIApplication.shared.dismissKeyboard()
                let networkStatus: NetworkStatus = CheckNetworkStatus()
                if(networkStatus == NetworkStatus.reachable){
                  Saving = true
                }
                if(networkStatus == NetworkStatus.notConnected){ ShowOfflineOverlay = true }
              }){
                Text("SAVE")
                  .font(.system(size: 12, weight: .bold))
                  .foregroundColor(Color("Text"))
              }
              .frame(width: UIScreen.main.bounds.size.width*0.15, height: 25)
              .background(RoundedRectangle(cornerRadius: 3).fill(Color("Secondary")))
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
          }
        }
        
        ZStack{
          HStack{
            ZStack(alignment: .bottom){
              Text("Allow others to invite")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(Color("Text"))
                .frame(width: UIScreen.main.bounds.size.width*0.65, height: 25, alignment: .leading)
            }
            .padding(.leading, 5)
            ZStack{
              if(!(channel?.SharePermission ?? false)){
                Button(action: {
                  let networkStatus: NetworkStatus = CheckNetworkStatus()
                  if(networkStatus == NetworkStatus.reachable){
                    if let rm = channel{
                      rm.SharePermission = true
                      ShowShareEnabledOverlay = true
                      Task{  try await FirebaseManager.UpdateRoomSharePermission(Room: rm) }
                    }
                  }
                  if(networkStatus == NetworkStatus.notConnected){ ShowOfflineOverlay = true }
                }){
                  Text("OFF")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(Color("Tertiary"))
                }
                .frame(width: UIScreen.main.bounds.size.width*0.15, height: 25)
                .background(RoundedRectangle(cornerRadius: 3).fill(Color("Secondary")).shadow(color: Color("Shadow"), radius: 1))
              }
              if(channel?.SharePermission ?? false){
                Button(action: {
                  let networkStatus: NetworkStatus = CheckNetworkStatus()
                  if(networkStatus == NetworkStatus.reachable){
                    if let rm = channel{
                      rm.SharePermission = false
                      Task{  try await FirebaseManager.UpdateRoomSharePermission(Room: rm) }
                    }
                  }
                  if(networkStatus == NetworkStatus.notConnected){ ShowOfflineOverlay = true }
                }){
                  Text("ON")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(Color("Label"))
                }
                .frame(width: UIScreen.main.bounds.size.width*0.15, height: 25)
                .background(RoundedRectangle(cornerRadius: 3).fill(Color("Tertiary")).shadow(color: Color("Tertiary"), radius: 1))
              }
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
          }
        }
        .frame(width: UIScreen.main.bounds.size.width*0.9, alignment: .leading)
        ZStack{
          HStack{
            ZStack(alignment: .bottom){
              Text("Allow others to become host")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(Color("Text"))
                .frame(width: UIScreen.main.bounds.size.width*0.65, height: 25, alignment: .leading)
            }
            .padding(.leading, 5)
            ZStack{
              if(!(channel?.BecomeHostPermission ?? false)){
                Button(action: {
                  let networkStatus: NetworkStatus = CheckNetworkStatus()
                  if(networkStatus == NetworkStatus.reachable){
                    if let rm = channel{
                      rm.BecomeHostPermission = true
                      ShowBecomeHostEnabledOverlay = true
                      Task{  try await FirebaseManager.UpdateRoomBecomeHostPermission(Room: rm) }
                    }
                  }
                  if(networkStatus == NetworkStatus.notConnected){ ShowOfflineOverlay = true }
                }){
                  Text("OFF")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(Color("Tertiary"))
                }
                .frame(width: UIScreen.main.bounds.size.width*0.15, height: 25)
                .background(RoundedRectangle(cornerRadius: 3).fill(Color("Secondary")).shadow(color: Color("Shadow"), radius: 1))
              }
              if(channel?.BecomeHostPermission ?? false){
                Button(action: {
                  let networkStatus: NetworkStatus = CheckNetworkStatus()
                  if(networkStatus == NetworkStatus.reachable){
                    if let rm = channel{
                      rm.BecomeHostPermission = false
                      Task{  try await FirebaseManager.UpdateRoomBecomeHostPermission(Room: rm) }
                    }
                  }
                  if(networkStatus == NetworkStatus.notConnected){ ShowOfflineOverlay = true }
                }){
                  Text("ON")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(Color("Label"))
                }
                .frame(width: UIScreen.main.bounds.size.width*0.15, height: 25)
                .background(RoundedRectangle(cornerRadius: 3).fill(Color("Tertiary")).shadow(color: Color("Tertiary"), radius: 1))
              }
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
          }
          .frame(width: UIScreen.main.bounds.size.width*0.9, alignment: .leading)
        }
        Button(action: {
          Task{
            Deleting = true
          }
        }){
          Text("Delete Session")
            .font(.system(size: 18, weight: .bold))
            .foregroundColor(Color("Red"))
        }
        
        if(SaveResponse){
          Spacer().frame(height: 0).onAppear{
            Task{
              if let chnl = channel{
                if(!NewRoomName.isEmpty){
                  UIApplication.shared.dismissKeyboard()
                  NewRoomName = FormatTextFieldInputKeepWhitespace(Input: NewRoomName)
                  try await FirebaseManager.UpdateRoomName(Room: chnl, Name: NewRoomName)
                  NameChange = true
                }
              }
            }
          }
        }
        
        if(DeleteResponse){
          Spacer().frame(height: 0).onAppear{
            Task{
              if let rm: Room = channel{
                try await AccountManager.deleteChannel(room: rm)
                FirebaseManager.RemoveObservers(Room: rm)
                Selected = false
                UIApplication.shared.dismissKeyboard()
                DeleteResponse = false
                Presentation.wrappedValue.dismiss()
              }
            }
          }
        }
      }
      .frame(maxWidth: UIScreen.main.bounds.size.width*0.9, maxHeight: UIScreen.main.bounds.size.height*0.65, alignment: .top)
      if(reload){ Spacer().frame(height: 0).onAppear{ reload = false } }
    }
    .frame(maxHeight: UIScreen.main.bounds.size.height)
    .onTapGesture { UIApplication.shared.dismissKeyboard() }
    .onAppear{ reload = true }
    .task{
      Task{
        channel = try await FirebaseManager.FetchRoomByID(ID: RoomID)
        // MARK: Firebase Listener [channel Updates]
        if let chnl = channel{
          if let chnl: Room = channel{ NewRoomName = chnl.Name }
          FirebaseManager.GetRoomUpdates(room: chnl, completion: { UpdatedRoom, Status in
            Task{
              if(Status == "success"){
                try await chnl.ReplaceAll(Room: UpdatedRoom)
                reload = true
              }
            }
          })
        }
      }
    }
    .gesture(DragGesture(minimumDistance: 10, coordinateSpace: .global)
      .onEnded{ position in
        let HorizontalDrag = position.translation.width
        let VerticalDrag = position.translation.height
        if(abs(HorizontalDrag) > abs(VerticalDrag)){
          if(HorizontalDrag > 0){
            if let chnl: Room = channel{ FirebaseManager.RemoveObservers(Room: chnl) }
            Presentation.wrappedValue.dismiss()
          }
        }
      })
    .navigationBarHidden(true)
    .ignoresSafeArea(.keyboard, edges: .all)
    .zIndex(1)
  }
}
