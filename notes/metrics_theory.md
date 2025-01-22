---
title: "Notes on Metrics"
author: "Devid Rosa"
date: "2025-01-14"
output: html_document
---

# The Kantorovich Problem

The Kantorovich problem calculates the distance between two probability measures.

**Definition:**

Let \((X, \mathcal{X})\) and \((Y, \mathcal{Y})\) be two Polish spaces, that is, complete and separable metric spaces.  
Consider two probability measures \(P\) and \(Q\) belonging to the set of probability measures on \(X\) and \(Y\), respectively, denoted by \(\mathcal{P}(X)\) and \(\mathcal{P}(Y)\).

We define the set:

$$
\Pi(P, Q) := \bigl\{\pi \in \mathcal{P}(X \times Y) :
\pi(X \times \cdot) = P(\cdot),\ \pi(\cdot \times Y) = Q(\cdot)\bigr\},
$$

which is the class of probability measures on \((X \times Y, \mathcal{X} \times \mathcal{Y})\) whose marginals are \(P\) and \(Q\).  
The elements \(\pi\) of this class are called transport plans.

All elements of \(\Pi\) are probability measures that can be interpreted as ways to transfer the "mass" from \(P\) to \(Q\).

The cost of moving this "mass" is defined by the cost function:

$$
c(\cdot,\cdot) : X \times Y \to \mathbb{R}.
$$

Given a transport plan \(\pi \in \Pi\), we define the average cost:

$$
I_c(\pi) := \int_{X \times Y} c(x,y)\,\pi(dx\,dy).
$$

The Kantorovich problem is then formulated as:

$$
K_c(P, Q) := \inf_{\pi \in \Pi} \int_{X \times Y} c(x,y)\,\pi(dx\,dy).
$$

Assuming \(X = Y\) and letting \(d\) be a distance on \(X\), the Wasserstein distance of order \(p\), denoted \(W_p\), is defined as:

$$
W_p(P, Q) := K_{d^p}(P, Q)^{1/p}
= \biggl(\inf_{\pi \in \Pi(P, Q)} \int_{X^2} d^p(x, y)\,\pi(dx\,dy)\biggr)^{\!\!1/p}.
$$

The difference between the Kantorovich and Wasserstein definitions lies in the cost function, \(d(x,y)^p\), where \(d(\cdot,\cdot)\) is a distance on \(X\). This cost function ensures, via the following proposition, that \(W_p\) is indeed a distance.

**Proposition**  
Assume \(X = Y\) and for \(p > 1\), \(c(x, y) = d(x, y)^p\), where \(d\) is a distance on \(X\), satisfying:

1. \(d(x, y) = d(y, x) \geq 0\);
2. \(d(x, y) = 0\) if and only if \(x = y\);
3. \(\forall (x, y, z) \in X^3, \ d(x, z) \leq d(x, y) + d(y, z)\).

Then \(W_p\) is a distance, meaning it is symmetric, positive, satisfies \(W_p(P, Q) = 0\) if and only if \(P = Q\), and fulfills the triangle inequality:

$$
\forall (P, Q, Z) \in \mathcal{P}(X)^3, \quad
W_p(P, Z) \leq W_p(P, Q) + W_p(Q, Z).
$$

# The Discrete Case

The Kantorovich problem can also be expressed in discrete form.

**Definition:** Suppose \(X = \{x_1, \dots, x_n\}\) and \(Y = \{y_1, \dots, y_m\}\).  
In this case, \(P\) and \(Q\) are represented by probability vectors \(a \in \Sigma_n\) and \(b \in \Sigma_m\), where:

$$
\Sigma_n = \bigl\{a \in \mathbb{R}_+^n : \sum_{i=1}^n a_i = 1\bigr\}.
$$

These vectors can be thought of as histograms, with each \(a_i\) representing the probability associated with \(x_i\) and each \(b_j\) with \(y_j\).

The discrete analogue of \(\Pi(P, Q)\) is defined as:

$$
U(a, b) := \bigl\{P \in \mathbb{R}_+^{n \times m} : P\,\mathbf{1}_m = a, \; P^\top \mathbf{1}_n = b\bigr\},
$$

where \(P\) is the transport matrix, the discrete counterpart of the transport plan \(\pi\). Here, \(P\_{i,j}\) indicates how much mass is moved from \(x_i\) to \(y_j\).

The cost matrix \(\mathbf{C} \in \mathbb{R}^{n \times m}\) represents the cost \(C\_{i,j} = c(x_i, y_j)\).  
The average cost is defined as:

$$
\bar{I}_c = \sum_{i,j} C_{i,j} \, P_{i,j}.
$$

The discrete Kantorovich problem is then:

$$
L_C(a, b) := \min_{P \in U(a, b)} \sum_{i,j} C_{i,j} \, P_{i,j}.
$$

In the Wasserstein case, we consider the cost matrix \(\mathbf{C} = \mathbf{D}\), where \(\mathbf{D}\) is the matrix of distances (e.g., Euclidean).

# Jensen–Shannon Divergence

The Jensen–Shannon divergence (JSD) measures the similarity between two probability distributions.

**Definition:** Let \(P\) and \(Q\) be two discrete probability distributions over the same domain \(\Omega\). Define:

$$
M = \tfrac{1}{2}(P + Q),
$$

the average distribution. The JSD is:

$$
\mathrm{JSD}(P \,\|\, Q) = \tfrac{1}{2}\mathrm{KL}(P \,\|\, M) + \tfrac{1}{2}\mathrm{KL}(Q \,\|\, M),
$$

where \(\mathrm{KL}\) is the Kullback-Leibler divergence:

$$
\mathrm{KL}(P \,\|\, Q) = \sum_{x \in \Omega} P(x) \,\log\!\biggl(\frac{P(x)}{Q(x)}\biggr).
$$

**Properties:**

1. **Symmetry**: \(\mathrm{JSD}(P \,\|\, Q) = \mathrm{JSD}(Q \,\|\, P)\).
2. **Non-negativity**: \(\mathrm{JSD}(P \,\|\, Q) \geq 0\), with equality if \(P = Q\).
3. **Boundedness**: \(0 \leq \mathrm{JSD}(P \,\|\, Q) \leq \log(2)\).
4. **Metric Property**: \(\sqrt{\mathrm{JSD}(P \,\|\, Q)}\) satisfies the triangle inequality.
