---
title: "Notes on metrics"
author: "Devid Rosa"
date: "2025-01-14"
output: html_document
---

# The Kantorovich Problem

The Kantorovich problem calculates the distance between two probability measures.

**Definition:**

Let \((X, \mathcal{X})\) and \((Y, \mathcal{Y})\) be two Polish spaces, that is, complete and separable metric spaces.
Consider two probability measures \(P\) and \(Q\) belonging to the set of probability measures on \(X\) and \(Y\),
respectively denoted by \(\mathcal{P}(X)\) and \(\mathcal{P}(Y)\).

We define the set

$$
\Pi(P,Q) := \bigl\{\pi \in \mathcal{P}(X \times Y) :
\pi(X \times \cdot) = P(\cdot),\ \pi(\cdot \times Y) = Q(\cdot)\bigr\},
$$

which is the class of probability measures on \((X \times Y,\, \mathcal{X} \times \mathcal{Y})\)
whose marginals are \(P\) and \(Q\). The elements \(\pi\) of this class are called transport plans.

All elements of \(\Pi\) are probability measures that can be interpreted as ways to transfer the "mass" from \(P\) to \(Q\).

However, moving this "mass" has a cost, defined by the cost function

$$
c(\cdot,\cdot) : X \times Y \to \mathbb{R}.
$$

Then, once a transport plan \(\pi \in \Pi\) is fixed, we define

$$
I_c(\pi) := \int_{X \times Y} c(x,y)\,\pi(dx\,dy),
$$

which represents the average cost of transferring \(P\) to \(Q\), associated with that particular transport plan.

We can therefore formulate the Kantorovich problem as follows:

$$
K_c(P,Q) := \inf_{\pi \in \Pi} \int_{X \times Y} c(x,y)\,\pi(dx\,dy).
$$

Having defined the Kantorovich problem, we now assume that \(X = Y\) and let \(d\) be a distance on \(X\).  
We can then define the Wasserstein distance of order \(p\), denoted \(W_p\), as follows:

$$
W_p(P,Q)
:= K_{d^p}(P,Q)^{1/p}
= \biggl(\inf_{\pi \in \Pi(P,Q)} \int_{X^2} d^p(x,y)\,\pi(dx\,dy)\biggr)^{\!\!1/p}.
$$

The difference between the Kantorovich definition and the Wasserstein definition lies in the cost function,
which is given by \(d(x,y)^p\), where \(d(\cdot,\cdot)\) is a distance on \(X\). It is precisely this definition
of the cost function that guarantees, via the following proposition, that \(W_p\) is indeed a distance.

**Proposition**  
Assume \(X = Y\) and that for \(p > 1\), \(c(x,y) = d(x,y)^p\), where \(d\) is a distance on \(X\), i.e.:

1. \(d(x,y) = d(y,x) \geq 0\);
2. \(d(x,y) = 0\) if and only if \(x = y\);
3. \(\forall (x,y,z) \in X^3,\ d(x,z) \le d(x,y) + d(y,z)\).

Then \(W_p\) is a distance, namely it is symmetric, positive, satisfies \(W_p(P,Q) = 0\)
if and only if \(P = Q\), and fulfills the triangle inequality:

$$
\forall (P,Q,Z) \in \mathcal{P}(X)^3 \quad
W_p(P,Z) \le W_p(P,Q) + W_p(Q,Z).
$$

# The Discrete Case

The Kantorovich problem can also be expressed in discrete form.

**Definition:** suppose \(X = \{ x_1, \dots, x_n \}\) and \(Y = \{ y_1, \dots, y_m \}\).
In this case, \(P\) and \(Q\) can be identified with two probability vectors
\(a \in \Sigma_n\) and \(b \in \Sigma_m\), where

$$
\Sigma_n
= \bigl\{ a \in \mathbb{R}_+^n : \sum_{i=1}^n a_i = 1 \bigr\}.
$$

These probability vectors can be thought of as histograms, in which
each \(a_i\) represents the probability associated with \(x_i\), and each \(b_j\)
represents the probability associated with \(y_j\).

We can define the discrete analogue of the set of probability measures
\(\Pi(P,Q)\) as follows:

$$
U(a, b) := \bigl\{\, P \in \mathbb{R}_+^{n \times m} :
P\,\mathbf{1}_m = a,\; P^\top \mathbf{1}_n = b \bigr\},
$$

where \(P\) is the transport matrix, the discrete analogue of
the transport plan \(\pi\). In other words,
\(P\_{i,j}\) tells us how much mass to move from the point \(x_i\) to the point \(y_j\).

From bin \(i\) of \(a\) to bin \(j\) of \(b\). The constraints related to the set \(U(a,b)\)
are similar to those of \(\Pi\), meaning that the sum of the rows or columns
returns \(a\) or \(b\), so that \(P\,\mathbf{1}_m = a = \sum_{j=1}^m P*{i,j}\)
for each \(i \in \{1,\dots,n\}\) and \(P^\top \mathbf{1}\_n = \sum*{i=1}^n P\_{i,j} = b_j\)
for each \(j \in \{1,\dots,m\}\).

The cost function \(\mathbf{c}\) is represented by a matrix \(\mathbf{C} \in \mathbb{R}^{n \times m}\),
where each \(C\_{i,j} = c(x_i, y_j)\) explains the cost of going from \(a_i\) to \(b_j\).
The average cost analogous to \(I_c\) in the discrete case is defined as

$$
\bar{I}_c
= \sum_{i,j} C_{i,j} \, P_{i,j}.
$$

We can then formulate the discrete Kantorovich problem as follows:

$$
L_C(a,b)
:= \min_{P \in U(a,b)} \sum_{i,j} C_{i,j} \, P_{i,j}.
$$

As in the continuous case, assuming \(X, Y \subset E\), with \(E\) a metric space
equipped with a distance \(d\), we can also define the Wasserstein distance
of order \(p\) in the discrete setting:

$$
W_p(a,b)
:= \min_{P \in U(a,b)}
\biggl(\sum_{i,j} D_{i,j}^p \, P_{i,j}\biggr)^{\!\!1/p}.
$$

where \(D*{i,j}^p = d^p(x_i, y_j)\) is the matrix of distances between the points \(x_i\) and \(y_j\).  
If \(X,Y \subset \mathbb{R}^n\), a standard example of distance between two points in the discrete case
is \(D*{i,j} = \|x_i - y_j\|\), where \(\|\cdot\|\) is the Euclidean norm.

In the Wasserstein case, we consider the cost matrix \(\mathbf{C} = \mathbf{D}\),
with \(\mathbf{D}\) being the matrix of Euclidean distances.

# MIAO

# Jensen–Shannon Divergence

The Jensen–Shannon divergence (JSD) is a measure of similarity (or dissimilarity) between two probability distributions.

**Definition:** let \(P\) and \(Q\) be two discrete probability distributions over the same domain \(\Omega\). Define

\[
M = \tfrac{1}{2}\,(P + Q),
\]

which is the average (or midpoint) distribution of \(P\) and \(Q\). Then the Jensen–Shannon divergence between \(P\) and \(Q\) is given by

\[
\mathrm{JSD}(P \,\|\, Q)
= \tfrac{1}{2}\,\mathrm{KL}(P \,\|\, M)

- \tfrac{1}{2}\,\mathrm{KL}(Q \,\|\, M),
  \]

where \(\mathrm{KL}(\cdot \,\|\, \cdot)\) denotes the KL divergence, defined by:

\[
\mathrm{KL}(P \,\|\, Q)
= \sum\_{x \in \Omega} P(x) \,\log\!\Bigl(\tfrac{P(x)}{Q(x)}\Bigr).
\]

**Properties:**

1. **Symmetry**  
   \[
   \mathrm{JSD}(P \,\|\, Q) = \mathrm{JSD}(Q \,\|\, P).
   \]
   This follows because \(M\) is symmetric in \(P\) and \(Q\).

2. **Non-negativity**  
   \[
   \mathrm{JSD}(P \,\|\, Q) \ge 0,
   \]
   with equality if and only if \(P = Q\).

3. **Boundedness**  
   \[
   0 \,\le\, \mathrm{JSD}(P \,\|\, Q) \,\le\, \log(2).
   \]
   The maximum value \(\log(2)\) occurs when \(P\) and \(Q\) have disjoint supports.

4. **Metric Property**  
   Taking the square root gives a metric:
   \[
   d\_{\mathrm{JSD}}(P, Q) := \sqrt{\mathrm{JSD}(P \,\|\, Q)}.
   \]
   This metric satisfies the triangle inequality.
