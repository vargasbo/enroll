# frozen_string_literal: true

require 'rails_helper'
RSpec.describe Forms::QualifyingLifeEventKindForm, type: :model, dbclean: :after_each do

  before :all do
    DatabaseCleaner.clean
  end

  context 'for for_new' do
    let!(:qlek) { FactoryBot.create(:qualifying_life_event_kind, is_active: true) }

    before :each do
      invoke_dry_types_script
      @qlek_form = Forms::QualifyingLifeEventKindForm.for_new
    end

    it 'should initialize QualifyingLifeEventKindForm object' do
      expect(@qlek_form).to be_a(Forms::QualifyingLifeEventKindForm)
    end

    it 'should set some effective kinds for ivl' do
      expect(@qlek_form.ivl_effective_kinds).to eq(['date_of_event', 'exact_date', 'first_of_month', 'first_of_next_month', 'fixed_first_of_next_month'])
    end

    it 'should set some effective kinds for shop' do
      expect(@qlek_form.shop_effective_kinds).to eq(['date_of_event', 'first_of_next_month', 'first_of_this_month', 'fixed_first_of_next_month'])
    end

    it 'should set some effective kinds for fehb' do
      expect(@qlek_form.fehb_effective_kinds).to eq(['date_of_event', 'first_of_next_month', 'first_of_this_month', 'fixed_first_of_next_month'])
    end

    it 'should set reasons for shop' do
      expect(@qlek_form.shop_reasons).to include(['Marriage', 'marriage'])
    end
  end

  context 'for for_edit' do
    let!(:qlek) { FactoryBot.create(:qualifying_life_event_kind, is_active: true) }

    before :each do
      invoke_dry_types_script
      @qlek_form = Forms::QualifyingLifeEventKindForm.for_edit({:id => qlek.id.to_s})
    end

    it 'should set title value on to the QualifyingLifeEventKindForm title' do
      expect(@qlek_form.title).to eq(qlek.title)
    end

    it 'should set id value on to the QualifyingLifeEventKindForm id' do
      expect(@qlek_form._id.to_s).to eq(qlek.id.to_s)
    end

    it 'should set post_event_sep_in_days value on to the QualifyingLifeEventKindForm post_event_sep_in_days' do
      expect(@qlek_form.post_event_sep_in_days).to eq(qlek.post_event_sep_in_days)
    end

    it 'should set market_kind value on to the QualifyingLifeEventKindForm market_kind' do
      expect(@qlek_form.market_kind).to eq(qlek.market_kind)
    end
  end

  context 'for for_update' do
    let!(:qlek) { FactoryBot.create(:qualifying_life_event_kind, is_active: true) }
    let(:update_params){ qlek.attributes.merge({:_id => qlek.id.to_s, :market_kind => 'individual'}) }

    before :each do
      invoke_dry_types_script
      @qlek_form = Forms::QualifyingLifeEventKindForm.for_update(update_params)
    end

    it 'should set title value on to the QualifyingLifeEventKindForm title' do
      expect(@qlek_form.title).to eq(qlek.title)
    end

    it 'should set id value on to the QualifyingLifeEventKindForm id' do
      expect(@qlek_form._id.to_s).to eq(qlek.id.to_s)
    end

    it 'should set post_event_sep_in_days value on to the QualifyingLifeEventKindForm post_event_sep_in_days' do
      expect(@qlek_form.post_event_sep_in_days).to eq(qlek.post_event_sep_in_days)
    end

    it 'should set market_kind value as individual and not shop' do
      expect(@qlek_form.market_kind).not_to eq(qlek.market_kind)
      expect(@qlek_form.market_kind).to eq('individual')
    end
  end

  context 'for for_clone' do
    let!(:qlek) { FactoryBot.create(:qualifying_life_event_kind, is_active: true) }

    before :each do
      invoke_dry_types_script
      @qlek_form = Forms::QualifyingLifeEventKindForm.for_clone({:id => qlek.id.to_s})
    end

    it 'should set title value on to the QualifyingLifeEventKindForm title' do
      expect(@qlek_form.title).to eq(qlek.title)
    end

    it 'should not set ID on to the QualifyingLifeEventKindForm' do
      expect(@qlek_form._id.to_s).to eq('')
    end

    it 'should not set START DATE on to the QualifyingLifeEventKindForm' do
      expect(@qlek_form.start_on).to eq(nil)
    end

    it 'should not set END DATE on to the QualifyingLifeEventKindForm' do
      expect(@qlek_form.end_on).to eq(nil)
    end

    it 'should set oridinal position on to the QualifyingLifeEventKindForm to 0' do
      expect(@qlek_form.ordinal_position).to eq(nil)
    end

    it 'should set post_event_sep_in_days value on to the QualifyingLifeEventKindForm post_event_sep_in_days' do
      expect(@qlek_form.post_event_sep_in_days).to eq(qlek.post_event_sep_in_days)
    end

    it 'should set market_kind value on to the QualifyingLifeEventKindForm market_kind' do
      expect(@qlek_form.market_kind).to eq(qlek.market_kind)
    end

    it 'should set tool_tip value on to the QualifyingLifeEventKindForm' do
      expect(@qlek_form.tool_tip).to eq(qlek.tool_tip)
    end

    it 'should set pre_event_sep_in_days value on to the QualifyingLifeEventKindForm' do
      expect(@qlek_form.pre_event_sep_in_days).to eq(qlek.pre_event_sep_in_days)
    end

    it 'should set is_self_attested value on to the QualifyingLifeEventKindForm' do
      expect(@qlek_form.is_self_attested).to eq(qlek.is_self_attested)
    end

    it 'should set effective_on_kinds value on to the QualifyingLifeEventKindForm' do
      expect(@qlek_form.effective_on_kinds).to eq(qlek.effective_on_kinds)
    end

    it 'should set date_options_available value on to the QualifyingLifeEventKindForm' do
      expect(@qlek_form.date_options_available).to eq(qlek.date_options_available)
    end

    it 'should set is_visible value on to the QualifyingLifeEventKindForm' do
      expect(@qlek_form.is_visible).to eq(qlek.is_visible)
    end

    it 'should set event_kind_label value on to the QualifyingLifeEventKindForm' do
      expect(@qlek_form.event_kind_label).to eq(qlek.event_kind_label)
    end
  end

  def invoke_dry_types_script
    consts = ['IndividualQleReasons', 'ShopQleReasons',
              'FehbQleReasons', 'IndividualEffectiveOnKinds',
              'ShopEffectiveOnKinds', 'FehbEffectiveOnKinds']
    types_module_constants = Types.constants(false)
    consts.each {|const| Types.send(:remove_const, const.to_sym) if types_module_constants.include?(const.to_sym)}
    load File.join(Rails.root, 'app/domain/types.rb')
  end
end