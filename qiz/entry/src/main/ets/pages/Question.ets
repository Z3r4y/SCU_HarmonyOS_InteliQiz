import router from '@ohos.router';
import { question, record, user as fetchUser } from '../api/API';
import QuestionModel from '../model/QuestionModel';
import ResponseData from '../model/ResponseData';
import UserModel from '../model/UserModel';


@Entry
@Component
struct RadioExample {
  @State Pitch: boolean = false;
  @State selectedOption: string = '';
  @State ToF: string = '';
  @State questionData: QuestionModel = {};
  @State currentPage: number = 1;
  @State user: UserModel = {};


  aboutToAppear() {
    this.loadQuestion();
  }

  async loadQuestion() {
    const response = await question(this.currentPage);
    if (response.responseCode == 200) {
      const responseData: ResponseData<QuestionModel> = JSON.parse(response.result as string);
      if (responseData.code == 0 && responseData.data !== undefined) {
        this.questionData = responseData.data;
        this.Pitch = false;
      }
    }
  }

  async submitAnswer(selectedOption: string) {
    const token = AppStorage.get<string>("token");
    if (token) {
      const userResponse = await fetchUser(token);
      if (userResponse.responseCode == 200) {
        const responseData: ResponseData<UserModel> = JSON.parse(userResponse.result as string);
        if (responseData.code == 0 && responseData.data) {
          let userData = responseData.data;

          const recordResponse = await record({
            userphone: userData.userphone,
            answer: selectedOption,
            question_id: this.questionData.id
          });
            }
          } else {
            console.error("Failed to record answer.");
          }
        } else {
          console.error('Failed to fetch user data');
        }
      }

  build() {
    Column() {
      Row() {
        Text("答题中")
          .fontColor(Color.White)
          .fontSize(30)
          .fontWeight(FontWeight.Medium);
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceAround)
      .backgroundImage($r('app.media.star')).opacity(0.8)
      .width('100%')
      .height(50);

      Row() {
        Text(this.questionData.question || "")
          .fontSize(20).margin({top:15})
          .fontWeight(FontWeight.Bold);
      }
      Image(this.questionData.image_url).borderRadius(15).height(150);
      Divider();
      Row() {
        Text("A:" + (this.questionData.option_a || ""))
          .fontWeight(FontWeight.Bold)
          .margin({top:10, left:20, right:20})
          .fontSize(20)
          .width('100%');
      }
      Row() {
        Text("B:" + (this.questionData.option_b || ""))
          .fontWeight(FontWeight.Bold)
          .margin({top:10, left:20, right:20})
          .fontSize(20)
          .width('100%');
      }

      Flex({ direction: FlexDirection.Row, justifyContent: FlexAlign.Center, alignItems: ItemAlign.Center }) {
        Column() {
          Text('A')
          Radio({ value: 'A', group: 'option' }).checked(this.selectedOption === 'A')
            .height(45)
            .width(45)
            .onChange((isChecked: boolean) => {
              this.Pitch = true;
              this.ToF = this.questionData.correct_option === 'A' ? '1' : '2';
              this.selectedOption = 'A';
            });
        }.width('100%');
        Column() {
          Text('B')
          Radio({ value: 'B', group: 'option' }).checked(this.selectedOption === 'B')
            .height(45)
            .width(45)
            .onChange((isChecked: boolean) => {
              this.Pitch = true;
              this.ToF = this.questionData.correct_option === 'B' ? '1' : '2';
              this.selectedOption = 'B';
            });
        }.width('100%');
      }.padding({ top: 30 });

      Column() {
        if (this.Pitch == true) {
          Image($r('app.media.next')).height(60).width('100%').onClick(() => {
            this.submitAnswer(this.selectedOption);
            if(this.currentPage==10){
              router.pushUrl({url:'pages/Rank'})
            }
            this.currentPage += 1;
            this.Pitch = false;
            this.selectedOption = '';
            this.ToF = '';
            this.loadQuestion();
          });
          Text("解析：")
            .fontSize(20)
            .width('100%');

          Text(this.questionData.explanation || "")
          Column() {
            Text("               恭喜！你……")
              .width('100%')
              .height(70)
              .fontSize(25)
              .fontColor(Color.Black)
              .fontWeight(FontWeight.Bold)
              .margin({top:50});
            Text(
              this.ToF == '1' ? "              答对了喵" : "           答错了QAQ"
            ).width('100%').height(70).fontSize(30).fontColor(this.ToF === '1' ? Color.Green : Color.Blue)
              .fontSize(this.ToF === '1' ? 30 : 30).fontWeight(FontWeight.Bold);
          }.width('100%')
          .margin({top:30})
          .backgroundImage($r('app.media.gongxi'))
          .height('100%');
        } else {
          Text("请先答题");
        }
      }.width('100%').margin({top:-10});
    }
    .width('100%')
    .height('100%')
    .backgroundImage($r('app.media.bei'));
  }
}
