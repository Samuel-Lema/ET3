/* Initial beliefs and rules */

/* Initial goals */

/* Plans */

+!emptyTrashcan: trashcan(full)[source(myRobot)] <- 
    empty_trashcan(trash);
    !emptyTrashcan.


+!emptyTrashcan <- !emptyTrashcan.