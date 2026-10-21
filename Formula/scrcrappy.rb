# Homebrew formula for the atreb92/scrcrappy tap (copy to Formula/scrcrappy.rb there; see docs/releasing.md).
# Linuxbrew (x86_64) builds the patched qvh; macOS has no qvh (video comes from AVFoundation), so no Go there.
# Untested on macOS. usbmuxd comes from the distro on Linux.
class Scrcrappy < Formula
  desc "Mirror and control an iPhone over USB (scrcpy for iOS)"
  homepage "https://github.com/atreb92/scrcrappy"
  url "https://github.com/Atreb92/scrcrappy/archive/refs/tags/v0.3.0.tar.gz"
  sha256 "cc6ae07024c0f94eb8843003161f4df70730c34ceaada1c5fa57c2398a3a66ed"
  license "MIT"

  depends_on "libusb"
  depends_on "python@3.13"

  on_linux do
    depends_on "go" => :build
    depends_on "pkg-config" => :build

    # Same pin as scripts/build-qvh.sh
    resource "qvh" do
      url "https://github.com/danielpaulus/quicktime_video_hack.git",
          revision: "d81396e2e7758d98c2a594853b64f98b54a8a871"
    end
  end

  def install
    if OS.linux?
      resource("qvh").stage buildpath/"qvh-src"
      system "sh", "scripts/build-qvh.sh", buildpath/"qvh-src" # patched, no GStreamer -> scrcrappy/bin/qvh
    end

    # Personal tap: dependencies come as PyPI wheels (pygame-ce bundles SDL, av bundles FFmpeg). A plain venv from
    # python@3.13's opt path survives Python patch upgrades; Homebrew's virtualenv_create makes it without pip, and
    # pip_install forces building every dependency from source.
    system Formula["python@3.13"].opt_bin/"python3.13", "-m", "venv", libexec
    system libexec/"bin/pip", "install", buildpath
    bin.install_symlink libexec/"bin/scrcrappy"
  end

  test do
    assert_match "usage: scrcrappy", shell_output("#{bin}/scrcrappy --help")
  end
end
