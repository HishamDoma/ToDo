import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:todos/controllers/task_controller.dart';
import 'package:todos/models/task.dart';
import 'package:todos/ui/theme.dart';
import 'package:todos/ui/widgets/button.dart';
import 'package:todos/ui/widgets/input_field.dart';

class AddTaskPage extends StatefulWidget{
  
  const AddTaskPage({Key? key}): super(key: key);

  @override
  State<AddTaskPage> createState() => _AddTaskPageState();
}

class _AddTaskPageState extends State<AddTaskPage> {
  final TaskController _taskController = Get.put(TaskController());
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  String _endTime="9:30 PM";
  String _startTime = DateFormat("hh:mm a").format(DateTime.now()).toString();
  int _selectedRemind=5;
  List<int> remindList=[
    5,
    10,
    15,
    20
  ];
  String _selectedRepeat= "None";
  List<String> repeatList=[
    "None",
    "Daily",
    "Weekly",
    "Monthly"
  ];
  int _selectedColor = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.theme.backgroundColor,
      appBar: _appbar(context) ,
      body: Container(
        padding:const EdgeInsets.only(left:10,right: 10),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Text("Add Task",
              style: headingStyle,
              ),
              MyInputField(title: "Title", hint: "Enter Your Title",controller: _titleController,),
              MyInputField(title: "Note", hint: "Enter Your Note",controller: _noteController,),
              MyInputField(title: "Date", hint: DateFormat.yMd().format(_selectedDate),
              widget: IconButton(onPressed: 
              (){
                setState(() {
                  _getDateFromUser();
                });
              }
              , icon: const Icon(Icons.calendar_today_outlined,color: Colors.grey,)), ),
              Row(
                children: [
                Expanded(
                  child: MyInputField(
                    title: "Start Date", 
                    hint:_startTime,
                    widget: IconButton(
                      onPressed: (){
                        _getTimeFromUser(isStartTime: true);
                      },
                      icon:const Icon(
                        Icons.access_alarms_rounded,
                        color: Colors.grey,
                      )),
                    ),
                    ),
                    const SizedBox(width: 12,),
                    Expanded(
                  child: MyInputField(
                    title: "End Date", 
                    hint:_endTime,
                    widget: IconButton(
                      onPressed: (){
                        _getTimeFromUser(isStartTime: false);
                      },
                      icon:const Icon( 
                        Icons.access_alarms_rounded,
                        color: Colors.grey,
                      )),
                    ),
                    ),
                     
              ],),
              MyInputField(title: "Remind", hint: "$_selectedRemind minuits early",
              widget: DropdownButton(
                icon: const Icon(Icons.keyboard_arrow_down,
                color: Colors.grey,),
                iconSize: 32,
                elevation: 4,
                style: subTitleStyle,
                underline: Container(height: 0,),
                onChanged: (String? newValue){
                  setState(() {
                    _selectedRemind = int.parse(newValue!);
                  });
                },
                items: remindList.map<DropdownMenuItem<String>>((int value){
                  return DropdownMenuItem<String>(
                    value: value.toString(),
                    child: Text(value.toString()
                    )
                    );
                }
                  ).toList(),
              ),),
              MyInputField(title: "Repeat", hint: "$_selectedRepeat ",
              widget: DropdownButton(
                icon: const Icon(Icons.keyboard_arrow_down,
                color: Colors.grey,),
                iconSize: 32,
                elevation: 4,
                style: subTitleStyle,
                underline: Container(height: 0,),
                onChanged: (String? newValue){
                  setState(() {
                    _selectedRepeat = newValue!;
                  });
                },
                items: repeatList.map<DropdownMenuItem<String>>((String? value){
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value!,style: const TextStyle(color: Colors.grey)
                    )
                    );
                }
                  ).toList(),
                
                
              ),),
              SizedBox(height: 14.0,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _colorPallette(),
                  MyButton(label: "Create Task", onTap: ()=>_validateData())
              ],)

            ],
            ),
        ),
      ),
    );
  }


   _validateData(){
     if(_titleController.text.isNotEmpty&& _noteController.text.isNotEmpty){
       _addTaskToDb();
       Get.back();
     }else if (_titleController.text.isEmpty || _noteController.text.isEmpty){
       Get.snackbar("Required", "All File are  required !",
       snackPosition: SnackPosition.BOTTOM,
       backgroundColor: Colors.white,
       colorText: pinkClr,
       icon: const Icon(Icons.warning_amber_rounded,color: Colors.red)
       );
     }
   }

   _addTaskToDb()async{
   int value = await _taskController.addTask(
      task:Task(
      note: _noteController.text,
      title: _titleController.text,
      date: DateFormat.yMd().format(_selectedDate),
      startTime: _startTime,
      endTime: _endTime,
      remind: _selectedRemind,
      repeat: _selectedRepeat,
      color: _selectedColor,
      isCompleted: 0,
    ),
    );
    print("kkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkk");
    print("My id is "+"$value");
   }


   _appbar(BuildContext context){
    return AppBar(
      elevation: 0,
      backgroundColor: context.theme.backgroundColor,
      leading: GestureDetector(
        onTap: (){
          Get.back();
        },
        child: Icon(Icons.arrow_back_ios,
           size: 30,
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

  _colorPallette(){
    return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Color",style: titleStyle,),
                      SizedBox(height: 8.0,),
                      Wrap(
                        children: List<Widget>.generate(
                          3,
                          (int index){
                            return GestureDetector(
                              onTap: (){
                                setState(() {
                                  _selectedColor=index;
                                });
                              },
                              child: Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: CircleAvatar(
                                  // ignore: prefer_const_constructors
                                  child: _selectedColor==index?Icon(Icons.done,
                                  color:Colors.white,
                                  size: 16,
                                  ):Container(),
                                  radius:14,
                                  backgroundColor: index == 0?primaryClr:index==1?pinkClr:yellowClr,
                                ),
                              ),
                            );
                          }
                        ),
                      )

                    ],
                  );
  }
  _getDateFromUser()async{
    DateTime? _pickerDate =await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2012),
      lastDate: DateTime(2121));
      if(_pickerDate!=null)
      {
        setState(() {
          _selectedDate=_pickerDate;
        });
        
      }
  }

  _getTimeFromUser({required bool isStartTime})async{
   var pickedTime= await  _showTimePicker();
   String _formattedTime = pickedTime.format(context);
   if(pickedTime==null){
     print("time canceld");
   }else if(isStartTime==true){
     setState(() {
       _startTime=_formattedTime;
     });
     
   }else if(isStartTime == false){
     setState(() {
        _endTime=_formattedTime;
     });
   }
  }


  _showTimePicker(){
    return showTimePicker(
      initialEntryMode: TimePickerEntryMode.input,
      context: context, 
      initialTime: TimeOfDay(
        hour: int.parse(_startTime.split(":")[0]),
         minute: int.parse(_startTime.split(":")[1].split(" ")[0])
         ),
         );
  }

}