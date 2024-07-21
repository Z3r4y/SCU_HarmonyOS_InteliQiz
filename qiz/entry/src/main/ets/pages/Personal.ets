import router from '@ohos.router'
import UserModel from '../model/UserModel'
import ResponseData from '../model/ResponseData'
import {fetchUsers} from '../api/API'

@Entry
@Component


struct PageFifteen {
  @State message: string = 'Hello World'
  @State userInformation: UserModel[] = [];

  aboutToAppear() {
    this.loadUsers();
  }

  async loadUsers() {
    const response = await fetchUsers(); // 从 API 获取用户数据
    if (response.responseCode === 200) {
      let responseData: ResponseData<UserModel[]> = JSON.parse(response.result as string) as ResponseData<UserModel[]>;
      if (responseData.code === 0 && responseData.data !== undefined) {
        const userArray: UserModel[] = [];
        for (const userData of responseData.data) {
          const userModel: UserModel = {
            uid: userData.uid,
            username: userData.username,
            userphone: userData.userphone,
            password: userData.password,
            trueNumber: userData.trueNumber,
            rate: userData.rate,
          };
          userArray.push(userModel);
        }
        this.userInformation = userArray;
      } else {
        console.error('Failed to fetch users:', responseData.msg);
      }
    }
  }


  build() {

    Column() {
      Row() {
        Image($r('app.media.back'))
          .backgroundColor(Color.White)
          .width(40)
          .borderRadius(10)
          .height(40)
          .margin({top:10})

          .onClick(()=>{
            router.back()
          })
        Text("个人情况")
          .fontSize(30)
          .fontWeight(700)
          .margin({ top: 10 ,left:70})
          .fontColor(Color.White)

      }.width('100%')


      Column() {

        ForEach(this.userInformation, (item: UserModel, index) => {
          if(item.username == AppStorage.Get<string>("Presentation"))
            Column() {
              Row() {
                Text(`答对个数：${item.trueNumber}`)
                  .fontSize(19)
                  .margin({ left: 5 })
                  .width('90%')
              }.backgroundColor("#00DFFF")
              .borderRadius(10)
              .height(40)
              .margin({ top: 10 })

              Row() {
                Text(`正确率：${item.rate}%`)
                  .fontSize(19)
                  .margin({ left: 5 })
                  .width('90%')
                  .fontColor(Color.White)
              }.backgroundColor(Color.Gray)
              .borderRadius(10)
              .height(40)
              .margin({ top: 10 })
              Button("返回").onClick(() => {
                router.back()
              })
            }


        }, (item: UserModel, index: number) => JSON.stringify(item) + index)

      }
    }.backgroundImage($r('app.media.backfifteen')).backgroundImageSize(ImageSize.Cover)
    .width('100%')
    .height('100%')
  }
}