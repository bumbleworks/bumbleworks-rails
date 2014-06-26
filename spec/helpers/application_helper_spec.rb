describe Bumbleworks::Rails::ApplicationHelper do
  let(:main_app) { double('Main App') }
  before(:each) do
    allow(helper).to receive(:main_app).and_return(main_app)
  end

  describe '#method_missing' do
    it "delegates to main_app if method_is_main_app_url_helper" do
      allow(main_app).to receive(:valid_method).with(:args).and_return(:valid_return)
      allow(helper).to receive(:method_is_main_app_url_helper?).
        with(:valid_method).and_return(true)

      expect(helper.method_missing(:valid_method, :args)).to eq(:valid_return)
    end

    it "raises NoMethodError unless method_is_main_app_url_helper" do
      allow(helper).to receive(:method_is_main_app_url_helper?).
        with(:invalid_method).and_return(false)

      expect {
        helper.method_missing(:invalid_method, :args)
      }.to raise_error(NoMethodError)
    end
  end

  describe '#respond_to?' do
    it "returns true if method_is_main_app_url_helper" do
      allow(helper).to receive(:method_is_main_app_url_helper?).
        with(:valid_method).and_return(true)

      expect(helper.respond_to?(:valid_method)).to be_truthy
    end

    it "returns false unless method_is_main_app_url_helper" do
      allow(helper).to receive(:method_is_main_app_url_helper?).
        with(:invalid_method).and_return(false)

      expect(helper.respond_to?(:invalid_method)).to be_falsy
    end
  end

  describe '#method_is_main_app_url_helper?' do
    it "returns true if main_app responds to method and method is url helper" do
      [:foo_path, :foo_url].each do |method|
        allow(main_app).to receive(:respond_to?).with(method).and_return(true)
        expect(helper.method_is_main_app_url_helper?(method)).to be_truthy
      end
    end

    it "returns false if main_app does not respond_to method" do
      allow(main_app).to receive(:respond_to?).with(:stupid_path).and_return(false)
      expect(helper.method_is_main_app_url_helper?(:stupid_path)).to be_falsy
    end

    it "returns false if method is not url helper" do
      expect(helper.method_is_main_app_url_helper?(:foo)).to be_falsy
    end
  end
end