import SwiftUI

enum FeatureViews: String, CaseIterable, Identifiable {
  case likes, history
  var id: Self { self }
}

struct RoomFeatureInfoOverlay: View {
  let feature: FeatureViews
  let LikeInfo1: String = "Add likes as an Apple Music playlist"
  let LikeNote1: String = "Note: Must have connected your Apple Music in the Settings"
  let HistoryInfo1: String = "Requeue on playlist"
  let HistoryInfo2: String = "Like"
  
  @Binding var Show: Bool
  
  var body: some View {
    ZStack(alignment: .center){
      Rectangle()
        .fill(Color("Secondary").opacity(0.75))
        .frame(width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
        .edgesIgnoringSafeArea(.all)
        .zIndex(5)
        .overlay(
          ZStack{
            switch(feature){
            case FeatureViews.likes:
              ZStack{
                VStack{
                  VStack(spacing: 20){
                    HStack(alignment: .firstTextBaseline, spacing: 4){
                      ZStack{
                        Image(systemName: "heart.fill")
                          .font(.system(size: 15, weight: .bold))
                          .foregroundColor(Color("Tertiary"))
                      }
                      .frame(width: UIScreen.main.bounds.size.width*0.05, alignment: .leading)
                      Text("Likes")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(Color("Tertiary"))
                        .multilineTextAlignment(.leading)
                    }
                    .frame(width: UIScreen.main.bounds.size.width*0.75, alignment: .leading)
                    
                    ZStack{
                      VStack(alignment: .leading, spacing: 7){
                        Text("ADD")
                          .font(.system(size: 12, weight: .bold))
                          .foregroundColor(Color("Tertiary"))
                          .frame(width: UIScreen.main.bounds.size.width*0.15, height: 25)
                          .background(RoundedRectangle(cornerRadius: 3).fill(Color("Secondary")))
                        Text(LikeInfo1)
                          .font(.system(size: 14, weight: .medium))
                          .foregroundColor(Color("Text"))
                          .multilineTextAlignment(.leading)
                        Text(LikeNote1)
                          .font(.system(size: 12, weight: .thin))
                          .foregroundColor(Color("Text"))
                          .multilineTextAlignment(.leading)
                      }
                    }
                    .frame(width: UIScreen.main.bounds.size.width*0.75, alignment: .leading)
                  }
                  Button(action: { Show = false }){
                    ZStack{
                      Text("CLOSE")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(Color("Red"))
                    }
                    .padding(.top, 10)
                  }
                  .frame(alignment: .bottom)
                }
                .padding(20)
              }
              .frame(alignment: .center)
              .background(RoundedRectangle(cornerRadius: 3).fill(Color("Primary")).shadow(color: Color("Shadow").opacity(0.5), radius: 1))
              
            case FeatureViews.history:
              ZStack{
                VStack{
                  VStack(spacing: 20){
                    HStack(alignment: .firstTextBaseline, spacing: 4){
                      ZStack{
                        Image(systemName: "clock.arrow.circlepath")
                          .font(.system(size: 15, weight: .bold))
                          .foregroundColor(Color("Tertiary"))
                      }
                      .frame(width: UIScreen.main.bounds.size.width*0.05, alignment: .leading)
                      Text("History")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(Color("Tertiary"))
                        .multilineTextAlignment(.leading)
                    }
                    .frame(width: UIScreen.main.bounds.size.width*0.75, alignment: .leading)
                    
                    ZStack{
                      HStack(alignment: .firstTextBaseline, spacing: 4){
                        ZStack{
                          Image(systemName: "plus")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(Color("Tertiary"))
                        }
                        .frame(width: UIScreen.main.bounds.size.width*0.05, alignment: .leading)
                        Text(HistoryInfo1)
                          .font(.system(size: 14, weight: .medium))
                          .foregroundColor(Color("Text"))
                          .multilineTextAlignment(.leading)
                      }
                    }
                    .frame(width: UIScreen.main.bounds.size.width*0.75, alignment: .leading)
                    ZStack{
                      HStack(alignment: .firstTextBaseline, spacing: 4){
                        ZStack{
                          Image(systemName: "heart")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(Color("Tertiary"))
                        }
                        .frame(width: UIScreen.main.bounds.size.width*0.05, alignment: .leading)
                        Text(HistoryInfo2)
                          .font(.system(size: 14, weight: .medium))
                          .foregroundColor(Color("Text"))
                          .multilineTextAlignment(.leading)
                      }
                    }
                    .frame(width: UIScreen.main.bounds.size.width*0.75, alignment: .leading)
                  }
                  Button(action: { Show = false }){
                    ZStack{
                      Text("CLOSE")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(Color("Red"))
                    }
                    .padding(.top, 10)
                  }
                  .frame(alignment: .bottom)
                }
                .padding(20)
              }
              .frame(alignment: .center)
              .background(RoundedRectangle(cornerRadius: 3).fill(Color("Primary")).shadow(color: Color("Shadow").opacity(0.5), radius: 1))
            }
          }
        )
    }
    .frame(width: UIScreen.main.bounds.size.width*0.8, height: UIScreen.main.bounds.size.height*0.08, alignment: .center)
    .zIndex(5)
    .onTapGesture{ Show = false }
  }
}
