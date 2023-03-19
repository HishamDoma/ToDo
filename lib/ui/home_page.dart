import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:todos/controllers/task_controller.dart';
import 'package:todos/models/task.dart';
import 'package:todos/services/notification_services.dart';
import 'package:todos/services/theme_services.dart';
import 'package:todos/ui/add_task_bar.dart';
import 'package:todos/ui/theme.dart';
import 'package:todos/ui/widgets/button.dart';
import 'package:date_picker_timeline/date_picker_timeline.dart';
import 'package:todos/ui/widgets/task_tile.dart';

class HomePage extends StatefulWidget{
  @override
  _HomePageState createState() => _HomePageState();

}

class _HomePageState extends State<HomePage>{
  DateTime _selectedDate = DateTime.now();
  final _taskController = Get.put(TaskController());
  var notifyHelper;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _taskController.getTasks();
    notifyHelper=NotifyHelper();
    notifyHelper.initializeNotification();

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appbar(),
      backgroundColor: context.theme.backgroundColor,
      body: Column(
        children: [
          _addTaskBar(),
          _addDateBar(),
          const SizedBox(height: 20,),
          _showTasks(),

         
        ],
      ),
    );
  }

 _addDateBar(){
   return  Container(
            margin:const EdgeInsets.only(top:10,left: 10),
            child: DatePicker(
              DateTime.now(),
              height: 100,
              width: 80,
              initialSelectedDate: DateTime.now(),
              selectionColor: primaryClr,
              selectedTextColor: Colors.white,
              
              dateTextStyle: GoogleFonts.lato(
                // ignore: prefer_const_constructors
                textStyle: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              )
              ),
              dayTextStyle: GoogleFonts.lato(
                // ignore: prefer_const_constructors
                textStyle: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              )
              ),
              monthTextStyle: GoogleFonts.lato(
                // ignore: prefer_const_constructors
                textStyle: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              )
              ),
              onDateChange: (date){
                setState(() {
                  _selectedDate = date;
                });
                
              },
            ),
          )
          ;
 }

  _showTasks(){
    return Expanded(
      child: Obx(() {

        return ListView.builder(
          itemCount: _taskController.taskList.length,
          itemBuilder: (_,index){
          Task task = _taskController.taskList[index];
          if(task.repeat == 'Daily'){
            bool itsPM = false;
            // DateTime date = DateFormat.Hm().parse(task.startTime.toString());
            // var myTime = DateFormat("HH:MM").format(date);
            // print(task.startTime.toString());
            if(task.startTime.toString().contains('PM')){
              itsPM =true ;
            } //else {itsPM =false;}
            String test = task.startTime.toString().replaceAll('PM', '');
            test = test.replaceAll('AM', '');
             print("ssssssssssssssssssssss");
            // print(test);
            // print(date);
            // print(myTime);
            // print(int.parse(myTime.toString().split(":")[1]));
            // print(task.toJson());
            notifyHelper.scheduledNotification(
              itsPM?int.parse(test.toString().split(":")[0])+12:int.parse(test.toString().split(":")[0]),
              int.parse(test.toString().split(":")[1]),
              task
            );
            return  AnimationConfiguration.staggeredList(
            position: index,
             child: SlideAnimation(child: FadeInAnimation(
               child:Row(
                 children: [
                   GestureDetector(
                     onTap: (){
                      _showBottomSheet(context, task);
                     },
                     child: TaskTile(task),
                   )
                 ],
               ) ,
               )
               )
             );
          }
          if(task.date == DateFormat.yMd().format(_selectedDate)){
            return  AnimationConfiguration.staggeredList(
            position: index,
             child: SlideAnimation(child: FadeInAnimation(
               child:Row(
                 children: [
                   GestureDetector(
                     onTap: (){
                      _showBottomSheet(context, task);
                     },
                     child: TaskTile(task),
                   )
                 ],
               ) ,
               )
               )
             );
          }
          else {
            return Container();
            }
          
          
        });
      }) );
  }

  _addTaskBar(){
    return Container(
            margin: const EdgeInsets.only(left: 17,right: 17),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                    Text(DateFormat.yMMMMd().format(DateTime.now()),
                    style: subHeadingStyle,),
                    Text("Today",
                    style: headingStyle,)
                    ],
                  ),
                ),
                MyButton(label: "+ Add Task", onTap: () async {
                 await Get.to(()=>const AddTaskPage()); 
                  _taskController.getTasks();
                  }
                  
                  )
                
            ],),
          );
  }
 
 _showBottomSheet(BuildContext context,Task task){
   Get.bottomSheet(Container(
     padding: const EdgeInsets.only(top:4),
     height: task.isCompleted==1?
     MediaQuery.of(context).size.height * 0.24:
     MediaQuery.of(context).size.height * 0.32,
     color: Get.isDarkMode?darckGrayClr:Colors.white,
    child: Column(
      children: [
        Container(
          height: 6,
          width: 120,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Get.isDarkMode?Colors.grey[600]:Colors.grey[300]
          )
        ),
        const Spacer(),
        task.isCompleted==1
        ?Container():
        _bottomSheetButton(label: "Task Completed",
         onTap: (){
           _taskController.markTaskCompleated(task.id!);
           Get.back();

         },
         clr: primaryClr,
         context: context),
         
         _bottomSheetButton(label: "Delet Task",
         onTap: (){
           _taskController.delete(task);
           Get.back();

         },
         clr: Colors.red[500]!,
         context: context),
         const SizedBox(height: 20,),
         _bottomSheetButton(label: "Close",
         onTap: (){
           Get.back();

         },
         clr: Colors.red[500]!,
         isClose: true,
         context: context),
         const SizedBox(height: 10,),
      ],
    ),
   )
   );
 }

 _bottomSheetButton({required String label,required Function()? onTap,required Color clr,bool isClose=false,required BuildContext context}){
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin:const EdgeInsets.symmetric(vertical: 4),
        height:  55,
        width: MediaQuery.of(context).size.width * 0.9,
        
        decoration: BoxDecoration(
          border: Border.all(
            width: 2,
            color: isClose==true?Get.isDarkMode?Colors.grey[600]!:Colors.grey[300]!:clr
          ),
          borderRadius: BorderRadius.circular(20),
          color: isClose==true?Colors.transparent:clr,
        ),
        child: Center(
          child: Text(label,style: isClose?titleStyle:titleStyle.copyWith(color: Colors.white,)
          ),
         ),
    )
    );
 }
  _appbar(){
    return AppBar(
      elevation: 0,
      backgroundColor: context.theme.backgroundColor,
      leading: GestureDetector(
        onTap: (){
          ThemeServices().switchTheme();
          notifyHelper.displayNotification(
            title: "Theme Changed",
            body: Get.isDarkMode?"Activated Light Theme":"Activated Dark Theme");
        },
        child: Icon(Get.isDarkMode ?Icons.wb_sunny_outlined:Icons.nightlight_round ,size: 30,
        color: Get.isDarkMode ? Colors.white:Colors.black
        ),
        ),
        // ignore: prefer_const_literals_to_create_immutables
        actions: [
          const CircleAvatar(
            backgroundColor: Colors.transparent,
             backgroundImage:  AssetImage("images/icon.png",
            ),
          ),
          const SizedBox(width: 20,),

          ],
    );
  }



}