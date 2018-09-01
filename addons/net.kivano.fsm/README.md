# Finite state machine plugin for Godot engine
Finite state machine plugin for Godot.
It allows you to setup your states easily inside your project. 
Basically it consist of "Finite state machine" node which is able to hold child nodes that are representing individual states.
It's created with the ease of additional states creation in mind, you can create them automatically from FSM node inspector, you just need to write new state name and proper script file will be created automatically, and node will be added as a child to the FSM node. The file will be created in special "states" folder inside folder that's holding currently edited scene.

There are couple of options inside FSM node:
- one of the most interesting one is to automatically remove non active states from scene tree in runtime. This way you can attach various visuals to individuals states, which visuals wont be present if you decide to change state. State will be automatically readded to the scene if you decide to activate it.
- additionally you can choose where to write state transition logic, in manual mode you can manually change states from every point of your code. Or you can choose to hardcode transitions inside state scripts. In this scenario FSM after updating current state logic will ask this state if transition should happen. In this case you need to implement computeNextState() function and return next state name. 

For more informations on various options and how to use this node, check readme section of FSM node script.
