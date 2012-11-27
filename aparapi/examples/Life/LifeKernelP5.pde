public class LifeKernelP5 extends Kernel {

	private static final int ALIVE = -1;

	private static final int DEAD = -16777216;

	private final int[] imageData;
	
	private final int[][][] buffer;

	private final int width;

	private final int height;

	private final Range range;

	public LifeKernelP5(int _width, int _height, int[] pixels) {
		width = _width;
		height = _height;
		imageData = pixels;
		buffer = new int[9][9][9];
		range = Range.create(width * height, 256);// , 256);
		System.out.println("range = " + range);
	}

	@Override
	public void run() {
		int gid = getGlobalId();
		int to = gid;// + toBase;
		int from = gid;// + fromBase;
		int x = gid % width;
		int y = gid / width;

		if ((x == 0 || x == width - 1 || y == 0 || y == height - 1)) {
			// This pixel is on the border of the view, just keep existing value
			imageData[to] = imageData[from];
		} else {
			// Count the number of neighbors. We use (value&1x) to turn pixel
			// value into either 0 or 1
			int neighbors = 0;
			if (imageData[from - 1] == ALIVE)
				neighbors++; // EAST
			if (imageData[from + 1] == ALIVE)
				neighbors++; // EAST
			if (imageData[from - width - 1] == ALIVE)
				neighbors++; // EAST
			if (imageData[from - width] == ALIVE)
				neighbors++; // EAST
			if (imageData[from - width + 1] == ALIVE)
				neighbors++; // EAST
			if (imageData[from + width - 1] == ALIVE)
				neighbors++; // EAST
			if (imageData[from + width] == ALIVE)
				neighbors++; // EAST
			if (imageData[from + width + 1] == ALIVE)
				neighbors++; // EAST

			// The game of life logic
			if (neighbors == 3 || (neighbors == 2 && imageData[from] == ALIVE)) {
				imageData[gid] = ALIVE;
			} else {
				imageData[gid] = DEAD;
			}

		}

	}

	public void nextGeneration() {
		// swap fromBase and toBase
		execute(range);
	}

	public int[] getImageData() {
		return imageData;
	}
}
