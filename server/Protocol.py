class Action:
    STATUS          = -1
    SET_NICKNAME    = 0
    SEND_MESSAGE    = 1

class Status:
    NONE                    = -1

    ERROR_BAD_JSON          = 0
    ERROR_BAD_NICKNAME      = 1
    ERROR_NICKNAME_TAKEN    = 2

    SUCCESS_NICKNAME_SET    = 3
