
/**
 * Implementation of the Gray-Scott reaction diffusion model described in detail
 * on the links below:
 * <ul>
 * <li>http://groups.csail.mit.edu/mac/projects/amorphous/GrayScott/</li>
 * <li>http://ix.cs.uoregon.edu/~jlidbeck/java/rd/</li>
 * <li>http://www.mrob.com/pub/comp/xmorphia/</li>
 * </ul>
 *
 * Processing.org port by edumo.net :)
 */

import toxi.math.MathUtils;
import controlP5.ControlP5;
import com.amd.aparapi.*;
import controlP5.Slider2D;

	GreyScottKernelP5 lifeKernel;
	PImage img = null;

	long generations = 0;
	long start = System.currentTimeMillis();

	ControlP5 cp5;
	Slider2D fk;
	Slider2D dudv;



	int countGenerationsByRun = 3;

	 void setup() {
		size(1024, 512);

		background(255);
		loadPixels();

		this.lifeKernel = new GreyScottKernelP5(width, height, pixels, 0.02f,
				0.06f, 0.53f, 0.05f, null);

		lifeKernel.setRect(width / 2, height / 2, 20, 20);

		System.out.println("Execution mode = " + lifeKernel.getExecutionMode());

		updatePixels();

		cp5 = new ControlP5(this);
		fk = cp5.addSlider2D("f-k").setPosition(30, 40).setSize(100, 100)
				.setArrayValue(new float[] { 23f, 76f });
		dudv = cp5.addSlider2D("du-dv").setPosition(30, 150).setSize(100, 100)
				.setArrayValue(new float[] { 95f, 30f });

		img = loadImage("ti_yong.png");

	}

	 void draw() {

		lifeKernel.seedImage(img.pixels, img.width, img.height);

		lifeKernel.setF(fk.getArrayValue(0) / 1000f);
		lifeKernel.setK(fk.getArrayValue(1) / 1000f);
		lifeKernel.setdU(dudv.getArrayValue(0) / 1000f);
		lifeKernel.setdV(dudv.getArrayValue(1) / 1000f);

		lifeKernel.nextGeneration(3); // Work
										// is
										// performed
		lifeKernel.copy();

		if (mousePressed && !fk.isMouseOver() && !dudv.isMouseOver()) {
			lifeKernel.setRect(mouseX, mouseY, 10, 10);
		}

		if (lifeKernel.isExplicit()) {

			// lifeKernel.get(pixels); // We only pull
			// the imageData
			// when we
			// intend to use
			// it.

			List<ProfileInfo> profileInfo = lifeKernel.getProfileInfo();
			if (profileInfo != null) {
				for (ProfileInfo p : profileInfo) {
					System.out.println(" " + p.getType() + " " + p.getLabel()
							+ " " + (p.getStart() / 1000) + " .. "
							+ (p.getEnd() / 1000) + " "
							+ (p.getEnd() - p.getStart()) / 1000 + "us");
				}
				// System.out.println();
			}
		}

		generations++;
		long now = System.currentTimeMillis();
		if (now - start > 1000) {
			text(String.format("%5.2f", (generations * 1000.0) / (now - start)),
					10, 10);
			start = now;
			generations = 0;
		}

		updatePixels();
		fill(0);
		rect(0, 0, 100, 20);
		fill(255);
		text(frameRate, 10, 10);
	}

	public void keyPressed() {
		if (key == 'q') {
			countGenerationsByRun++;
			println(countGenerationsByRun);
		}
		if (key == 'a') {
			countGenerationsByRun--;
			println(countGenerationsByRun);
		}
		if (key == 'c') {
			lifeKernel.clear();
		}
	}

