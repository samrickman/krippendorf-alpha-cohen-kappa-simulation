generate_dummy_rater_data <- function(prop_negative_class = 0.9,
                                      error_rate = 0.2,
                                      num_samples = 300) {
    message(
        "Running simulation with paramaters:\n",
        "prop_negative_class: ", prop_negative_class,
        "\nerror_rate: ", error_rate,
        "\nnum_samples: ", num_samples
    )
    cm_no_error <- matrix(c(
        prop_negative_class, 0,
        0, (1 - prop_negative_class)
    ), byrow = TRUE, nrow = 2)

    # Apply the error to the correct rates
    cm_with_error <- cm_no_error * (1 - error_rate)

    # Move the difference to the incorrect rates
    # by making each row add up to the total
    cm_with_error[1, 2] <- cm_no_error[1, 1] - cm_with_error[1, 1]
    cm_with_error[2, 1] <- cm_no_error[2, 2] - cm_with_error[2, 2]

    colnames(cm_with_error) <- c("0", "1")
    rownames(cm_with_error) <- c("0", "1")

    message("Confusion matrix agreement proportions (rater 1 is rows)")
    print(cm_with_error)

    stopifnot(
        all.equal(rowSums(unname(cm_with_error)), rowSums(cm_no_error))
    )

    fn_proportion <- cm_with_error[2, 1]
    fp_proportion <- cm_with_error[1, 2]

    zeroes <- rep(0, num_samples * prop_negative_class)
    ones <- rep(1, num_samples * (1 - prop_negative_class))
    rater1 <- c(zeroes, ones)

    num_false_pos <- as.integer(fp_proportion * num_samples)
    num_false_neg <- as.integer(fn_proportion * num_samples)

    rater2_pos <- ones
    rater2_pos[1:num_false_neg] <- 0
    rater2_neg <- zeroes
    rater2_neg[1:num_false_pos] <- 1

    rater2 <- c(rater2_neg, rater2_pos)

    # Dummy 1 or 2 for rater id
    # as expected by kripp.alpha
    irr_matrix <- matrix(
        c(
            c(1, rater1),
            c(2, rater2)
        ),
        nrow = 2,
        byrow = T
    )

    return(irr_matrix)
}

get_cohen_kappa <- function(response_matrix, rater_id_first_col = TRUE) {
    rater1_responses <- response_matrix[1, ]
    rater2_responses <- response_matrix[2, ]

    if (rater_id_first_col) {
        rater1_responses <- rater1_responses[-1]
        rater2_responses <- rater2_responses[-1]
    }

    cohen_k <- table(rater1_responses, rater2_responses) |>
        psych::cohen.kappa()
    cohen_k_named_vec <- c(
        "cohen_k" = cohen_k$kappa,
        "cohen_k_lower" = cohen_k$confid[1, 1],
        "cohen_k_upper" = cohen_k$confid[1, 3]
    )
    return(cohen_k_named_vec)
}

get_k_alpha_boot <- function(response_matrix) {
    k_alpha <- kripp.boot(response_matrix)
    k_alpha_named_vec <- c(
        "alpha_boot" = k_alpha$mean.alpha,
        "lower_boot" = k_alpha$lower,
        "upper_boot" = k_alpha$upper
    )
    return(k_alpha_named_vec)
}

get_k_alpha_kap <- function(irr_matrix) {
    k_alpha_check <- krippendorffs.alpha(
        t(irr_matrix),
        level = "nominal",
        confint = TRUE,
        control = list(bootit = 1000, parallel = FALSE)
    )
    confint_check <- confint(k_alpha_check) |>
        setNames(c("lower_kap", "upper_kap"))
    alpha_check <- k_alpha_check$alpha.hat |>
        setNames("alpha_kap")

    return_vector <- c(alpha_check, confint_check)
    return(return_vector)
}

compare_bootstrap_estimates <- function(irr_matrix) {
    original_bootstrap_k <- get_k_alpha_boot(irr_matrix)
    k_alpha_check <- get_k_alpha_kap(irr_matrix)

    return(
        c(original_bootstrap_k, k_alpha_check)
    )
}

create_plotting_dirs <- function() {
    plots_created <- FALSE
    if (!dir.exists("./plots/")) {
        dir.create("plots")
        plots_created <- TRUE
    }
    if (!dir.exists("./simulated_data/")) {
        dir.create("simulated_data")
        plots_created <- TRUE
    }


    sub_dirs_to_create <- c(
        "kripp_alpha_comparison",
        "cohen_kappa",
        "kripp_alpha",
        "kappa_alpha_comparison"
    )
    sub_dirs_to_create <- paste0("plots/", sub_dirs_to_create)
    lapply(sub_dirs_to_create, \(directory){
        if (!dir.exists(directory)) {
            dir.create(directory)
            plots_created <<- TRUE
        }
    })
    if (plots_created) {
        message("Plot and data directories created...")
    } else {
        message("Plot and data directories already exist...")
    }
}

create_plotting_dirs()