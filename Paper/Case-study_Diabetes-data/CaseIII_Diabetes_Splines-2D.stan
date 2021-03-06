// generated with brms 2.8.0
functions {
}
data {
  int<lower=1> N;  // number of observations
  int Y[N];  // response variable
  int trials[N];  // number of trials
  // data for smooth terms
  int Ks;
  matrix[N, Ks] Xs;
  // data of smooth t2(x1,x2,k=2+kn[5])
  int nb_1;  // number of bases
  int knots_1[nb_1];
  matrix[N, knots_1[1]] Zs_1_1;
  matrix[N, knots_1[2]] Zs_1_2;
  matrix[N, knots_1[3]] Zs_1_3;
  int prior_only;  // should the likelihood be ignored?

  int<lower=1> N1;
  int ind1[N1];		# indices for training observations
  int<lower=1> N2;
  int ind2[N2];		# indices for testing observations

}
transformed data {
}
parameters {
  real temp_Intercept;  // temporary intercept
  // parameters for smooth terms
  vector[Ks] bs;
  // parameters of smooth t2(x1,x2,k=2+kn[5])
  vector[knots_1[1]] zs_1_1;
  real<lower=0> sds_1_1;
  vector[knots_1[2]] zs_1_2;
  real<lower=0> sds_1_2;
  vector[knots_1[3]] zs_1_3;
  real<lower=0> sds_1_3;
}
transformed parameters {
  vector[knots_1[1]] s_1_1 = sds_1_1 * zs_1_1;
  vector[knots_1[2]] s_1_2 = sds_1_2 * zs_1_2;
  vector[knots_1[3]] s_1_3 = sds_1_3 * zs_1_3;
}
model {
  vector[N1] mu_train = temp_Intercept + rep_vector(0, N1) + Xs[ind1,] * bs + Zs_1_1[ind1,] * s_1_1 + Zs_1_2[ind1,] * s_1_2 + Zs_1_3[ind1,] * s_1_3;
  // priors including all constants
  target += student_t_lpdf(temp_Intercept | 3, 0, 10);
  target += normal_lpdf(zs_1_1 | 0, 1);
  target += normal_lpdf(zs_1_2 | 0, 1);
  target += normal_lpdf(zs_1_3 | 0, 1);
  target += student_t_lpdf(sds_1_1 | 3, 0, 10)
    - 1 * student_t_lccdf(0 | 3, 0, 10);
  target += student_t_lpdf(sds_1_2 | 3, 0, 10)
    - 1 * student_t_lccdf(0 | 3, 0, 10);
  target += student_t_lpdf(sds_1_3 | 3, 0, 10)
    - 1 * student_t_lccdf(0 | 3, 0, 10);
  // likelihood including all constants
  if (!prior_only) {
    target += binomial_logit_lpmf(Y[ind1] | trials[ind1], mu_train);
  }
}
generated quantities {
  // actual population-level intercept
  real b_Intercept = temp_Intercept;

	vector[N1+N2] mu;
	vector[N1+N2] y_predict;
	vector[N1+N2] f_invlogit;
	vector[N1+N2] log_y_predict;
	
	mu = temp_Intercept + rep_vector(0, N1+N2) + Xs[1:(N1+N2),] * bs + Zs_1_1[1:(N1+N2),] * s_1_1 + Zs_1_2[1:(N1+N2),] * s_1_2 + Zs_1_3[1:(N1+N2),] * s_1_3;
		
	for(i in 1:(N1+N2)){
		y_predict[i] = binomial_rng(1, inv_logit(mu[i]));
		f_invlogit[i] = inv_logit(mu[i]);

		log_y_predict[i] =  binomial_logit_lpmf(Y[i] | 1, mu[i]);
	}
}
