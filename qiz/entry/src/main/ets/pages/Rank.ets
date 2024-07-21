import router from '@ohos.router';
import { fetchUsers } from '../api/API'; // 添加从API获取用户数据的方法
import UserModel from '../model/UserModel';
import { AnswerSituationModel } from '../model/AnswerSituationModel';
import ResponseData from '../model/ResponseData'

@Entry
@Component
struct PageFourteen {

  @State userInformation: UserModel[] = [];
  @StorageLink("answerSituation")
  answerSituations: AnswerSituationModel = { trueNumber: 0, rate: 0 };

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
        this.updateCurrentUser();
        this.sortUsers();
      } else {
        console.error('Failed to fetch users:', responseData.msg);
      }
    }
  }



  updateCurrentUser() {
    for (let index = 0; index < this.userInformation.length; index++) {
      const element = this.userInformation[index];
      if (this.answerSituations.userphone === element.userphone && this.answerSituations.password === element.password) {
        this.userInformation[index].trueNumber = this.answerSituations.trueNumber;
        this.userInformation[index].rate = this.answerSituations.rate;
      }
    }
  }

  sortUsers() {
    this.userInformation.sort((a, b) => (b.trueNumber ?? 0) - (a.trueNumber ?? 0));
  }

  build() {
    Column() {
      Row() {
        Text("排行榜")
          .fontSize(30)
          .fontWeight(700)
          .margin({ top: 10 })
          .fontColor("#F7CC04");
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceAround)
      .backgroundImage($r('app.media.star')).opacity(0.8)
      .width('100%')
      .height(50);

      Column() {
        ForEach(this.userInformation, (item: UserModel, index: number) => {
          Row() {
            Text(item.username)
              .fontSize(30)
              .fontWeight(700)
              .fontColor("#F7CC04");
            Image($r('app.media.back_icon'))
              .backgroundColor(Color.White)
              .width(40)
              .borderRadius(10)
              .height(50)
              .onClick(() => {
                AppStorage.SetOrCreate("Presentation",item.username)
                router.pushUrl({ url: "pages/Personal" });
              });
          }
          .backgroundColor("#F6F6F6")
          .width('90%')
          .height(50)
          .border({ width: 1, color: "#E6EEFF" })
          .backgroundColor("F1F8FF")
          .justifyContent(FlexAlign.SpaceBetween)
          .borderRadius(10)
          .margin({ top: 10 });
        }, (item: UserModel, index: number) => JSON.stringify(item) + index);
      }

      Button("退出登录").onClick(() => {
        router.pushUrl({ url: "pages/Login" });
      }).margin({ top: 10 });
    }
    .backgroundImage($r('app.media.backfourt2')).backgroundImageSize(ImageSize.Cover)
    .width('100%')
    .height('100%');
  }
}
