class Why3 < Formula
  desc "Platform for deductive program verification"
  homepage "http://why3.lri.fr/"
  url "https://gforge.inria.fr/frs/download.php/file/34797/why3-0.86.2.tar.gz"
  sha256 "a7ada8bec9b6717257f2932d8b42e5e3f2dd63800f5e9a3f4004229b0efe3389"

  depends_on "menhir"
  depends_on "ocaml"
  depends_on "coq" => :optional
  depends_on "hevea" => [:build, :optional]
  depends_on "lablgtk" => :optional
  depends_on "pkg-config" => :build
  depends_on "rubber" => :build

  def install
    system "./configure", "--enable-verbose-make",
                          "--prefix=#{prefix}"

    system "make"
    system "make", "install"
    elisp.install share/"emacs/site-lisp/why3.el"
    elisp.install share/"emacs/site-lisp/why3.elc"
  end

  test do
    (testpath/"max_sum.mlw").write <<-EOS.undent
      module MaxAndSum
        use import int.Int
        use import ref.Ref
        use import array.Array
        let max_sum (a: array int) (n: int)
          requires { 0 <= n = length a }
          requires { forall i:int. 0 <= i < n -> a[i] >= 0 }
          returns  { sum, max -> sum <= n * max }
        = let sum = ref 0 in
          let max = ref 0 in
          for i = 0 to n - 1 do
            invariant { !sum <= i * !max }
            if !max < a[i] then max := a[i];
            sum := !sum + a[i]
          done;
          (!sum, !max)
        let test () =
          let n = 10 in
          let a = make n 0 in
          a[0] <- 9; a[1] <- 5; a[2] <- 0; a[3] <- 2;  a[4] <- 7;
          a[5] <- 3; a[6] <- 2; a[7] <- 1; a[8] <- 10; a[9] <- 6;
          max_sum a n
      end
    EOS
    expected = <<-EOS.undent
      Execution of MaxAndSum.test ():
           type: (int, int)
         result: (45, 10)
        globals:
    EOS
    assert_equal expected.strip, shell_output("#{bin}/why3 execute max_sum.mlw MaxAndSum.test").strip
  end
end
