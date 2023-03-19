import 'package:get/get.dart';
import 'package:todos/db/db_helper.dart';
import 'package:todos/models/task.dart';

class TaskController extends GetxController{

  @override
  void onReady(){
    super.onReady();
  }


  var taskList = <Task>[].obs;


  Future<int> addTask({Task? task})async{
    return await DBHelper.insert(task);
  }

  void getTasks()async{
    List<Map<String,dynamic>> tasks = await DBHelper.query();
    taskList.assignAll(tasks.map((data) => new Task.fromjson(data)).toList());
  }


  void delete(Task task){
    var val =DBHelper.delete(task);
    getTasks();
  }

  void markTaskCompleated( int id )async{
    await DBHelper.update(id);
    getTasks();
  }

}