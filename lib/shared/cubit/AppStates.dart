abstract class AppStates {}

class InitialAppState extends AppStates {}



// Create Database
class SuccessCreateDataBaseAppState extends AppStates {}

class ErrorCreateDataBaseAppState extends AppStates {

  dynamic error;
  ErrorCreateDataBaseAppState(this.error);
}


// Insert Into Database
class SuccessInsertIntoDataBaseAppState extends AppStates {}

class ErrorInsertIntoDataBaseAppState extends AppStates {

  dynamic error;
  ErrorInsertIntoDataBaseAppState(this.error);
}


// Get From Database
class LoadingGetFromDataBaseAppState extends AppStates {}

class SuccessGetFromDataBaseAppState extends AppStates {}

class ErrorGetFromDataBaseAppState extends AppStates {

  dynamic error;
  ErrorGetFromDataBaseAppState(this.error);

}


// Update Into Database
class SuccessUpdateIntoDataBaseAppState extends AppStates {

  final bool isEmptyNote;
  SuccessUpdateIntoDataBaseAppState(this.isEmptyNote);
}

class ErrorUpdateIntoDataBaseAppState extends AppStates {

  dynamic error;
  ErrorUpdateIntoDataBaseAppState(this.error);
}


// Delete From Database
class SuccessDeleteFromDataBaseAppState extends AppStates {

  final bool isEmptyNote;
  SuccessDeleteFromDataBaseAppState(this.isEmptyNote);

}

class ErrorDeleteFromDataBaseAppState extends AppStates {

  dynamic error;
  ErrorDeleteFromDataBaseAppState(this.error);
}

class SuccessDeleteNoteFromDataBaseAppState extends AppStates {}

class ErrorDeleteNoteFromDataBaseAppState extends AppStates {

  dynamic error;
  ErrorDeleteNoteFromDataBaseAppState(this.error);
}

class SuccessDeleteAllNotesFromDataBaseAppState extends AppStates {}

class ErrorDeleteAllNotesFromDataBaseAppState extends AppStates {

  dynamic error;
  ErrorDeleteAllNotesFromDataBaseAppState(this.error);
}

// Pin Note
class SuccessPinNoteAppState extends AppStates {}

class ErrorPinNoteAppState extends AppStates {

  dynamic error;
  ErrorPinNoteAppState(this.error);
}

// Move To Recycle Bin
class SuccessMoveToRecycleBinAppState extends AppStates {}

class ErrorMoveToRecycleBinAppState extends AppStates {

  dynamic error;
  ErrorMoveToRecycleBinAppState(this.error);
}

class SuccessMoveSelectedNoteToRecycleBinAppState extends AppStates {}

class ErrorMoveSelectedNoteToRecycleBinAppState extends AppStates {

  dynamic error;
  ErrorMoveSelectedNoteToRecycleBinAppState(this.error);
}

class SuccessMoveAllSelectedNotesToRecycleBinAppState extends AppStates {}

class ErrorMoveAllSelectedNotesToRecycleBinAppState extends AppStates {

  dynamic error;
  ErrorMoveAllSelectedNotesToRecycleBinAppState(this.error);
}


// Restore From Recycle Bin
class SuccessRestoreFromRecycleBinAppState extends AppStates {}

class ErrorRestoreFromRecycleBinAppState extends AppStates {

  dynamic error;
  ErrorRestoreFromRecycleBinAppState(this.error);
}

class SuccessRestoreNoteFromRecycleBinAppState extends AppStates {}

class ErrorRestoreNoteFromRecycleBinAppState extends AppStates {

  dynamic error;
  ErrorRestoreNoteFromRecycleBinAppState(this.error);
}

class SuccessRestoreAllNotesFromRecycleBinAppState extends AppStates {}


class SuccessSelectNoteAppState extends AppStates {}

class SuccessCancelSelectNoteAppState extends AppStates {}

class SuccessSearchNoteAppState extends AppStates {}

class SuccessClearAppState extends AppStates {}

class SuccessDetectLangTextAppState extends AppStates {}


// Image
class SuccessGetImageAppState extends AppStates {}

class ErrorGetImageAppState extends AppStates {

  dynamic error;
  ErrorGetImageAppState(this.error);

}

class SuccessAddImageNoteIntoDataBaseAppState extends AppStates {}

class ErrorAddImageNoteIntoDataBaseState extends AppStates {}

class SuccessGetImageNoteFromDataBaseAppState extends AppStates {}

class ErrorGetImageNoteFromDataBaseAppState extends AppStates {}

class SuccessUpdateImageNoteFromDataBaseAppState extends AppStates {}

class ErrorUpdateImageNoteFromDataBaseAppState extends AppStates {}

class SuccessDeleteImageNoteFromDataBaseAppState extends AppStates {}

class ErrorDeleteImageNoteFromDataBaseAppState extends AppStates {}
