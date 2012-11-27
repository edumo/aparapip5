
public class GreyScottKernelP5 extends Kernel {

	private final int[] imageData;

	private final int width;

	private final int height;

	private final Range range;

	protected float f, k;
	protected float dU, dV;

	public float[] u, v;
	protected float[] uu, vv;

	private final int[] colors = new int[250000];

	public GreyScottKernelP5(int _width, int _height, int[] pixels, float f,
			float k, float dU, float dV, int[] colors) {
		width = _width;
		height = _height;
		imageData = pixels;
		range = Range.create(width * height, 256);// , 256);
		System.out.println("range = " + range);
		// I CAN'T UPDATE THE PIXELS AT PAPPLET
		 setExplicit(true); // This gives us a performance boost
		// put(imageData); // Because we are using explicit buffer management we
		// must put the imageData array

		this.f = f;
		this.k = k;
		this.dU = dU;
		this.dV = dV;

		this.u = new float[width * height];
		this.v = new float[u.length];
		this.uu = new float[u.length];
		this.vv = new float[u.length];

		clear();

	}

	public void seedImage(int[] pixels, int imgWidth, int imgHeight) {

		int xo = MathUtils.clip((width - imgWidth) / 2, 0, width - 1);
		int yo = MathUtils.clip((height - imgHeight) / 2, 0, height - 1);
		imgWidth = MathUtils.min(imgWidth, width);
		imgHeight = MathUtils.min(imgHeight, height);
		for (int y = 0; y < imgHeight; y++) {
			int i = y * imgWidth;
			for (int x = 0; x < imgWidth; x++) {
				if (0 < (pixels[i + x] & 0xff)) {
					int idx = (yo + y) * width + xo + x;
					uu[idx] = 0.5f;
					vv[idx] = 0.25f;
				}
			}
		}
	}

	public void clear() {
		for (int i = 0; i < uu.length; i++) {
			uu[i] = 1.0f;
			vv[i] = 0.0f;
		}
	}


	public void setRect(int x, int y, int w, int h) {
		int mix = MathUtils.clip(x - w / 2, 0, width);
		int max = MathUtils.clip(x + w / 2, 0, width);
		int miy = MathUtils.clip(y - h / 2, 0, height);
		int may = MathUtils.clip(y + h / 2, 0, height);
		for (int yy = miy; yy < may; yy++) {
			for (int xx = mix; xx < max; xx++) {
				int idx = yy * width + xx;
				uu[idx] = 0.5f;
				vv[idx] = 0.25f;
			}
		}
	}

	public void copy() {
		System.arraycopy(u, 0, uu, 0, u.length);
		System.arraycopy(v, 0, vv, 0, v.length);
	}

	/**
	 * Extension point for subclasses to modulate the F coefficient of the
	 * reaction diffusion, based on spatial (or other) parameters. This method
	 * is called for every cell/pixel of the simulation space from the main
	 * {@link #update(float)} cycle and can be used to create parameter
	 * gradients, animations and other spatial or temporal modulations.
	 * 
	 * @param x
	 * @param y
	 * @return the active F coefficient at the given position
	 */
	public float getFCoeffAt(int x, int y) {
		return f;
	}

	/**
	 * Extension point for subclasses to modulate the K coefficient of the
	 * reaction diffusion, based on spatial (or other) parameters. This method
	 * is called for every cell/pixel of the simulation space and can be used to
	 * create parameter gradients, animations and other spatial or temporal
	 * modulations.
	 * 
	 * @param x
	 * @param y
	 * @return the active K coefficient at the given position
	 */
	public float getKCoeffAt(int x, int y) {
		return k;
	}

	@Override
	public void run() {
		int gid = getGlobalId();

		int x = gid % width;
		int y = gid / width;

		if ((x < 5 || x > width - 5 || y < 5 || y > height - 5)) {
			return;
		}

		int idx = gid;// y * width + x;
		int top = idx - width;
		int bottom = idx + width;
		int left = idx - 1;
		int right = idx + 1;

		float t = 2.1f;

		float currF = getFCoeffAt(x, y);
		float currK = getKCoeffAt(x, y);
		float currU = uu[idx];
		float currV = vv[idx];
		//
		float d2 = currU * currV * currV;

		float tempu = max(
				0,
				currU
						+ t
						* ((dU
								* ((uu[right] + uu[left] + uu[bottom] + uu[top]) - 4 * currU) - d2) + currF
								* (1.0f - currU)));

		float tempv = max(
				0,
				currV
						+ t
						* ((dV
								* ((vv[right] + vv[left] + vv[bottom] + vv[top]) - 4 * currV) + d2) - currK
								* currV));
		u[idx] = tempu;
		v[idx] = tempv;
		//
		int col = 255 - (int) (min(255, u[gid] * 768));
		imageData[gid] = col << 16 | col << 8 | col | 0xff000000;
		//
		//
		uu[gid] = tempu;
		vv[gid] = tempv;
		// }
	}

	public void nextGeneration(int vel) {
		// swap fromBase and toBase

		// execute(range, vel);
		execute(range, vel);
	}

	public int[] getImageData() {
		return imageData;
	}

	public float getF() {
		return f;
	}

	public void setF(float f) {
		this.f = f;
	}

	public float getK() {
		return k;
	}

	public void setK(float k) {
		this.k = k;
	}

	public float getdU() {
		return dU;
	}

	public void setdU(float dU) {
		this.dU = dU;
	}

	public float getdV() {
		return dV;
	}

	public void setdV(float dV) {
		this.dV = dV;
	}

}
