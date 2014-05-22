library Protocol;

class Action {
    static const num STATUS          = -1;
    static const num SET_NICKNAME    = 0;
    static const num SEND_MESSAGE    = 1;
}

class Status {
    static const num ERROR_BAD_JSON         = 0;
    static const num ERROR_BAD_NICKNAME     = 1;
    static const num ERROR_NICKNAME_TAKEN   = 2;

    static const num SUCCESS_NICKNAME_SET   = 3;
}
