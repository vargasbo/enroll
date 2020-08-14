module ResourceRegistryWorld

  def enable_feature(feature_key)
    return if EnrollRegistry.feature_enabled?(:financial_assistance)

    feature_dsl = EnrollRegistry[:financial_assistance]
    feature_dsl.feature.stub(:is_enabled).and_return(true)
  end

  def disable_feature(feature_key)
    return unless EnrollRegistry.feature_enabled?(:financial_assistance)

    feature_dsl = EnrollRegistry[:financial_assistance]
    feature_dsl.feature.stub(:is_enabled).and_return(false)
  end
end

World(ResourceRegistryWorld)
