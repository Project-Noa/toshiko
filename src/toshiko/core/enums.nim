# author: Ethosa

type
  NodeKind* {.pure.} = enum
    # default
    NODE_NODE,
    SCENE_NODE,
    CANVAS_NODE,
    # Control nodes
    CONTROL_NODE
  NodeType* {.pure.} = enum
    NODETYPE_DEFAULT,
    NODETYPE_CONTROL
  PauseMode* {.pure.} = enum
    PAUSE_MODE_PAUSE,
    PAUSE_MODE_RUN,
    PAUSE_MODE_INHERIT