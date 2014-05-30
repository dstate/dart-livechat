import 'dart:html';

import 'User.dart';

class UsersManager {
    UListElement    list;
    List<User>      users;

    UsersManager(UListElement list) {
        this.list = list;
        this.users = [];
    }

    List<User> getUsers() {
        return this.users;
    }

    User getUserByNickname(String nickname) {
        User user;

        try {
            user = this.users.firstWhere((User u) =>
                    u.getNickname() == nickname);
        } on StateError catch(e) {
            user = null;
        }
        return user;
    }

    void setUsers(List<User> users) {
        this.users = [];
        this.list.children.clear();
        users.forEach((User u) => this.addUser(u));
    }

    void addUser(User u) {
        LIElement newUser = new LIElement();
        newUser.text = u.getNickname();
        this.list.children.add(newUser);
        this.users.add(u);
    }

    void removeUser(User u) {
        this.list.children.removeWhere((LIElement elem) =>
                elem.text == u.getNickname());
        this.users.remove(u);
    }
}
