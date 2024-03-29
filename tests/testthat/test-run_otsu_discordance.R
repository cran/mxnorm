# helper function to skip tests if we don't have the 'foo' module
skip_if_no_skf <- function() {
    have_skf <- reticulate::py_module_available("skimage.filters")
    if (!have_skf)
        skip("skimage.filters not available for testing")
}

test_that("validate params works",{
    mx_obj = mx_dataset(data=mxnorm::mx_sample,
                         slide_id="slide_id",
                         image_id="image_id",
                         marker_cols=c("marker1_vals","marker2_vals","marker3_vals"),
                         metadata_cols=c("metadata1_vals"))
    ## validate parameters
    mx_obj = mx_normalize(mx_data=mx_obj,
                           transform="log10",
                           method="ComBat")

    ## table exists in list
    expect_error(validate_otsu_discordance_params(mx_obj,table="test",NULL,NULL))

    ## validate mx_dataset (copy from other tests)
    ## catches missing transform
    expect_error(validate_otsu_discordance_params(mx_obj[-7],"normalized",NULL,NULL))

    ## catches missing method
    expect_error(validate_otsu_discordance_params(mx_obj[-8],"normalized",NULL,NULL))

    ## catches Inf
    mx_obj$norm_data[1,5] = Inf
    expect_error(validate_otsu_discordance_params(mx_obj,"normalized",NULL,NULL))

    ## catches non-numerics
    mx_obj$norm_data[1,5] = "Inf"
    expect_error(validate_otsu_discordance_params(mx_obj,"normalized",NULL,NULL))

    ## catches NAs
    mx_obj$norm_data[1,5] = NA
    expect_error(validate_otsu_discordance_params(mx_obj,"normalized",NULL,NULL))

    ## catches incorrect dims
    mx_obj$norm_data <- data.frame(matrix(rnorm(9),3,3))
    expect_error(validate_otsu_discordance_params(mx_obj,"normalized",NULL,NULL))

    ## normalized data exists when "normalized" or "both
    expect_error(validate_otsu_discordance_params(mx_obj[-6],"normalized",NULL,NULL))
    expect_error(validate_otsu_discordance_params(mx_obj[-6],"both",NULL,NULL))

    ## threshold override is valid: in list if char, or isn't function
    expect_error(validate_otsu_discordance_params(mx_obj,"raw",NULL,"test"))
    expect_error(validate_otsu_discordance_params(mx_obj,"raw",NULL,list(1:10)))
})

test_that("threshold works",{
    ## thold override doesn't have thold data
    expect_error(get_discordance_thold(function(x){mean(x)}))

    ## thold override needs params
    expect_error(get_discordance_thold(function(thold_data,x){mean(thold_data)}))

    ## thold override has Inf, NAs
    expect_error(get_discordance_thold(function(thold_data){Inf}))
    expect_error(get_discordance_thold(function(thold_data){NA}))

    skip_if_no_skf()
    ## test other skf
    expect_equal(all(grepl("python",class(get_discordance_thold("li")))),TRUE)

    ## get otsu if null
    expect_equal(grepl("otsu",get_discordance_thold(NULL)),TRUE)
})

test_that("create dataset works",{
    mx_obj = mx_dataset(data=mxnorm::mx_sample,
                        slide_id="slide_id",
                        image_id="image_id",
                        marker_cols=c("marker1_vals","marker2_vals","marker3_vals"),
                        metadata_cols=c("metadata1_vals"))
    ## validate parameters
    mx_obj = mx_normalize(mx_data=mx_obj,
                          transform="log10",
                          method="ComBat")

    ## set correct threshold & validate
    skip_if_no_skf()
    threshold = get_discordance_thold(NULL)

    ## create otsu dataset
    mx_obj = otsu_mx_dataset(mx_obj,
                             table="both",
                             threshold)

    expect_equal(is.null(mx_obj$otsu_data),FALSE)
    expect_equal(unique(mx_obj$otsu_data$table),c("raw","normalized"))
})

test_that("discordance works",{
    mx_obj = mx_dataset(data=mxnorm::mx_sample,
                        slide_id="slide_id",
                        image_id="image_id",
                        marker_cols=c("marker1_vals","marker2_vals","marker3_vals"),
                        metadata_cols=c("metadata1_vals"))
    ## validate parameters
    mx_obj = mx_normalize(mx_data=mx_obj,
                          transform="log10",
                          method="ComBat")

    skip_if_no_skf()
    ## set correct threshold & validate
    threshold = get_discordance_thold(NULL)

    ## create otsu dataset
    mx_obj = otsu_mx_dataset(mx_obj,
                             table="both",
                             threshold)

    ## discordance
    mx_obj1 = otsu_mx_discordance(mx_obj,
                                       table="normalized")
    mx_obj2 = otsu_mx_discordance(mx_obj,
                                        table="both")

    ## check that error loads
    expect_equal(is.null(mx_obj1$otsu_data$discordance_score),FALSE)

    ## check that both works
    expect_equal(unique(mx_obj2$otsu_data$table),c("raw","normalized"))
})

test_that("plot out works",{
    ## create object
    mx_obj = mx_dataset(data=mxnorm::mx_sample,
                        slide_id="slide_id",
                        image_id="image_id",
                        marker_cols=c("marker1_vals","marker2_vals","marker3_vals"),
                        metadata_cols=c("metadata1_vals"))
    mx_obj = mx_normalize(mx_data=mx_obj,
                          transform="log10",
                          method="None")

    skip_if_no_skf()

    ## should print out
    mx_obj = run_otsu_discordance(mx_obj,
                                table="both",
                                threshold_override = NULL,
                                plot_out = TRUE)

    ## just confirm object exists as a simple test of plotting (e.g. no errors)
    expect_equal(class(mx_obj),"mx_dataset")
})
