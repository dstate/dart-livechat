class User {
    String nickname;

    User([String nickname = '']) {
        this.setNickname(nickname);
    }

    bool operator ==(User u) {
        return this.getNickname() == u.getNickname();
    }

    int get hashCode {
        return 42 + this.nickname.hashCode;
    }

    String getNickname() {
        return this.nickname;
    }

    void setNickname(String nickname) {
        this.nickname = nickname;
    }
}
