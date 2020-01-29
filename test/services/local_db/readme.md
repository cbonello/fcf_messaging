  final ChatMemberData md1 = ChatMemberData(
    userID: 'md1',
    name: 'md1',
    status: 'I am MD1',
    createdAt: Timestamp.now(),
  );
  final ChatMemberData md2 = ChatMemberData(
    userID: 'md2',
    name: 'md2',
    status: 'I am MD2',
    createdAt: Timestamp.now(),
  );
  final ChatMemberData md3 = ChatMemberData(
    userID: 'md3',
    name: 'md3',
    status: 'I am MD3',
    createdAt: Timestamp.now(),
  );
  final List<ChatMemberData> cmd1 = <ChatMemberData>[md1, md2];
  final List<ChatMemberData> cmd2 = <ChatMemberData>[md2, md1];
  cmd2.sort(
    (ChatMemberData m1, ChatMemberData m2) => m1.userID.compareTo(m2.userID),
  );
  final ChatModel cm1 = ChatModel(
    documentID: 'cm1',
    membersData: cmd1,
  );
  final ChatModel cm2 = ChatModel(
    documentID: 'cm1',
    membersData: cmd2,
  );
  final ChatModel cm3 = ChatModel(
    documentID: 'cm3',
    membersData: <ChatMemberData>[md1, md3],
  );

  print(cm1 == cm2);
  print(cm1 == cm3);
