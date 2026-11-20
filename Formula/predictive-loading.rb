class PredictiveLoading < Formula
  desc "Predicts your next DNS lookups from your own history and resolves them early"
  homepage "https://github.com/Questboy23/predictive-loading"
  url "https://github.com/Questboy23/predictive-loading/releases/download/v1.0/predictive-loading-1.0.0.tar.gz"
  sha256 "4ae777065fa3a26a381a59ddc610adb50ac8e4b212a2816b8fab6f15cbc5f040"
  license "MIT"

  depends_on :macos
  depends_on "python@3.13"
  depends_on "unbound"

  def install
    libexec.install "mac/lib/daemon.py", "mac/lib/dnsq.py", "mac/lib/cli.py",
                    "mac/lib/unbound.conf.in", "predictor/predictor.py"
    (bin/"predictive-loading").write <<~SH
      #!/bin/bash
      exec "#{Formula["python@3.13"].opt_bin}/python3.13" "#{opt_libexec}/cli.py" "$@"
    SH
  end

  def caveats
    <<~EOS
      Turn it on (one admin prompt):
        predictive-loading enable
      See time saved against the random 10% holdout:
        predictive-loading stats
      Before `brew uninstall`, restore DNS and delete all data:
        predictive-loading uninstall
    EOS
  end

  test do
    assert_match "predictive-loading enable", shell_output("#{bin}/predictive-loading help")
    system Formula["python@3.13"].opt_bin/"python3.13", "-c",
           "import sys; sys.path.insert(0, '#{opt_libexec}'); import predictor; p = predictor.Predictor(); " \
           "[p.observe(x) for x in 'abcabcabc']; assert p.predict(0, 1)[0][0] == 'a'"
  end
end
