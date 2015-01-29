// optimized im2col for n-dim data
// input:	image im[NxMxD] matrix
//			patch size p 
// output:	im2col[(p^2)x(NxM)] all p^2 sized patches ('sliding window') rastered in columns dim-by-dim
//
// scan direction along im rows
#include <mex.h>
#include <matrix.h>

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]) 
{
	double *im = mxGetPr(prhs[0]);
	int patch_row = mxGetScalar(prhs[1]);
	int patch_col = mxGetScalar(prhs[2]);
	const int *im_sz = mxGetDimensions(prhs[0]);
	int n_im_dim = mxGetNumberOfDimensions(prhs[0]);
	int nrows,ncols;
	int ndims = 1;
	if (n_im_dim<2 || n_im_dim>3)
	{
		mexErrMsgTxt("Unsupported number of input 1 dims should be 2 or 3");		
	} else {
		nrows = im_sz[0];
		ncols = im_sz[1];
	}
	if (nrows<patch_row || ncols<patch_col)
		mexErrMsgTxt("Input dim < patch size");
		
	if (n_im_dim==3)
		ndims = im_sz[2];
	
	int rows_out,cols_out;	
	double tmp;
	// create output var
	rows_out = patch_row*patch_col*ndims;
	cols_out = (nrows-patch_row+1)*(ncols-patch_col+1);
	plhs[0] = mxCreateDoubleMatrix(rows_out, cols_out, mxREAL);
	double *OUT = mxGetPr(plhs[0]);		
	// Loop over all blocks
	for (int c = 0 ; c < ncols-patch_col+1 ; c++) // cols	
	{
		double *im_c = &(im[c*nrows]);
		for (int r = 0 ; r < nrows-patch_row+1 ; r++) //rows
		{
			double *im_c_r = &(im_c[r]);
			for (int d = 0 ; d < ndims ; d++) //dims
			{
				// Loop for block elements 		
				double *im_c_r_d = &(im_c_r[d*(nrows*ncols)]);
				for(int cc = 0 ; cc < patch_col ; cc++)
				{
					double *im_c_r_d_cc = &(im_c_r_d[cc*nrows]);
					for(int rr = 0 ; rr < patch_row ; rr++)					
					{							
						*(OUT++) = im_c_r_d_cc[rr];							
					}
				}
			}
		}
	}
}