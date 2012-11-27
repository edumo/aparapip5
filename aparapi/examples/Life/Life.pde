/**
 * An example Aparapi application which demonstrates Conways 'Game Of Life'.
 * 
 * Original code from Witold Bolt's site https://github.com/houp/aparapi/tree/master/samples/gameoflife.
 * 
 * Converted to use int buffer and some performance tweaks by Gary Frost
 * 
 * @author Wiltold Bolt
 * @author Gary Frost
 *
 * Processing.org port by edumo.net :)
 *
 */


import com.amd.aparapi.*;

        LifeKernelP5 lifeKernel;
	PImage img = null;

	long generations = 0;
	long start = System.currentTimeMillis();

	public void setup() {
		size(1366, 768);

		background(0);

		fill(255);
		rect(0, height / 2, width, 200);

		loadPixels();

		//REMEMBER, EVERY OBJECT IS A POINTER!! pixels is the processing frame buffer.
		this.lifeKernel = new LifeKernelP5(width, height, pixels);
		// lifeKernel.setExecutionMode(EXECUTION_MODE.CPU);
		System.out.println("Execution mode = " + lifeKernel.getExecutionMode());

		updatePixels();
	}

	public static final int clip(int a, int min, int max) {
		return a < min ? min : (a > max ? max : a);
	}

	public void setRect(int x, int y, int w, int h, int[] pixels, int c) {

		int mix = clip(x - w / 2, 0, width);
		int max = clip(x + w / 2, 0, width);
		int miy = clip(y - h / 2, 0, height);
		int may = clip(y + h / 2, 0, height);

		for (int yy = miy; yy < may; yy++) {
			for (int xx = mix; xx < max; xx++) {
				int idx = yy * width + xx;
				pixels[idx] = c;
			}
		}
	}

	public void draw() {

		if (mousePressed) {
			setRect(mouseX, mouseY, 10, 10, pixels, color(255));
		}

		lifeKernel.nextGeneration(); // Work is performed here

		//update the pixels because aparapi has changed it
		updatePixels();
		
		fill(0);
		rect(0, 0, 100, 20);
		fill(255);
		text(frameRate, 10, 10);
	}
