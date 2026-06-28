#define COG_SMALL 1
#define COG_LARGE 2 // keep at double of COG_SMALL

//Relative connection directions
#define CONN_DIR_NONE		(1<<0)
#define CONN_DIR_FORWARD	(1<<1)
#define CONN_DIR_LEFT		(1<<2)
#define CONN_DIR_RIGHT		(1<<3)
#define CONN_DIR_FLIP		(1<<4)
#define CONN_DIR_Z_UP		(1<<5)
#define CONN_DIR_Z_DOWN		(1<<6)

//Placing behavior of rotation contraption items
#define PLACE_TOWARDS_USER	1

/// Hard cap on a network's total stress (capacity). Generators can never push this above the ceiling,
/// which guarantees the "energy without limit" accounting bug cannot make capacity run away.
#define MAX_ROTATION_STRESS 65535

/// Safety ceiling for rotation propagation. Propagation is a depth-first walk of the network graph;
/// without a cap, a long line of components blows the BYOND call stack and crashes the server.
/// A genuine network of this size is functionally unreachable in normal play.
#define MAX_ROTATION_PROPAGATION_DEPTH 500
