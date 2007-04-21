#!/usr/bin/perl
use encoding 'utf8';

# if you can't see correct perldoc output:
# perldoc -t check.pl

=head1 NAME

check.pl - A tool to check the syntax and consistency of libchewing's tsi.src

=head1 SYNOPSIS

    # 第一次使用
    $ ./check.pl < tsi.src > check.log
        # 仔細檢視整個輸出

    # 之後有新的 tsi.src 時
    $ ./check.pl < tsi.src > check.log.n
    $ diff check.log.n-1 check.log.n
        # 檢視相異部份


=head1 DESCRIPTION

這支小程式嘗試找出 tsi.src 中容易出問題需人工檢視的地方. 包括以下幾種檢查.

=over

=cut

$re_bpmf1 = qr/[ㄅㄆㄇㄈㄉㄊㄋㄌㄍㄎㄏㄐㄑㄒㄓㄔㄕㄖㄗㄘㄙ]/;
$re_bpmf2 = qr/[ㄧㄨㄩ]/;
$re_bpmf3 = qr/[ㄚㄛㄜㄝㄞㄟㄠㄡㄢㄣㄤㄥㄦ]/;
$re_bpmf4 = qr/[ˇˊˋ˙]/;

$re_bpmf = qr/$re_bpmf1?$re_bpmf2?$re_bpmf3?$re_bpmf4?/;

=pod

=item check syntax and duplication

檢查是否有重複的詞條, 或是格式錯誤.

=cut

print "check syntax and duplication\n";

binmode STDIN, ':utf8';
while(<>) {
    chomp;
    $lineno++;
    s/\s*#.*//;
    $rawdata[$lineno]=$_;
    if(s/\s+$//) {
      $rawdata[$lineno]=$_;
      wrong($lineno, "trailing space");
    }

    if (my($ci, $freq, $yinstr) = m/^(\S+) (\d+) ((?:$re_bpmf ?)+)$/) {
	my $len = length $ci;
	my @yin = split / /, $yinstr;
	my @zi = split //, $ci;
	if(scalar @yin == $len) {
	    if(exists $ciyinstr2line{$ci,$yinstr}) {
		wrong($ciyinstr2line{$ci,$yinstr}, "duplicated");
		wrong($lineno, "duplicated");
	    }
	    if($ci !~ /^[\x{ff}-\x{ffff}]+$/) {
		wrong($lineno, "unicode char > U+FFFF is not supported yet");
	    }
	    $ciyinstr2line{$ci,$yinstr}=$lineno;
	    push @{$ciyin{$ci}}, [@yin, $lineno];
	    push @{$yinstr2ci{$yinstr}}, $ci;
	    $freq[$lineno] = $freq;

	    for (0 .. $len-1) {
		$ziyinfreq{$zi[$_]}{$yin[$_]}+=$freq;
	    }
	    if ($len == 1) {
		$ziyin{$ci}{$yinstr}=();
	    }
	} else {
	    wrong($lineno, "ci-yin number mismatch");
	}
    } else {
	wrong($lineno, "syntax error");
    }
}
close F;
print "\n";

=pod

=item check all zi-yin pair has defined ziyin

檢查詞條中每個字的注音都有定義. 某些罕見字音, 或是特殊詞條的轉音沒有記錄是可以接受的.

=cut

print "check all zi-yin pair has defined ziyin\n";
for my $ci (sort keys %ciyin) {
    my $len = length $ci;
    for my $yinlist(@{$ciyin{$ci}}) {
	for(0 .. $len-1) {
	    my $zi = substr $ci, $_, 1;
	    my $yin = $yinlist->[$_];
	    if(!exists $ziyin{$zi}{$yin}) {
		wrong($yinlist->[$len], "$zi $yin doesn't have its own zi-yin entry");
	    }
	}
    }
}
print "\n";

%note = qw/ˊ 2 ˇ 3 ˋ 4 ˙ 5/;

=pod

=item check '一'

檢查 '一' 的轉音是否符合規則:

=over

=item * 單獨使用或詞尾讀一聲

=item * 在四聲、輕聲前讀二聲

=item * 在一、二、三聲前讀四聲

=back

由於各種因素, 沒轉音的一聲在所有的詞中都是允許的.

=cut

print "check '一'\n";
my @ok_yi;
$ok_yi[1][0]=
$ok_yi[1][1]=
$ok_yi[1][2]=
$ok_yi[1][3]=
$ok_yi[1][4]=
$ok_yi[1][5]=
$ok_yi[4][1]=
$ok_yi[4][2]=
$ok_yi[4][3]=
$ok_yi[2][4]=
$ok_yi[2][5]=1;
for my $ci (sort grep /一/, keys %ciyin) {
    my $len = length $ci;
    for my $yinlist(@{$ciyin{$ci}}) {
	my @yin = @$yinlist;
	my @num = map {
	    my $lastbpmf = substr $_, -1, 1;
	    $note{$lastbpmf} || 1
	} @yin;

	for my$i(0 .. $len-1) {
	    if(substr($ci, $i, 1) eq '一') {
		if(!$ok_yi[$num[$i]][$num[$i+1]]) {
		    print "$ci\t", @{$yinlist}[0..$len-1], "\t# 一\n";
		}
	    }
	}
    }
}
print "\n";

=pod

=item check '不'

檢查 '不' 的轉音是否符合規則:

=over

=item * 單獨使用或詞尾讀四聲

=item * 在四聲前讀二聲

=item * 在一、二、三聲前讀四聲

=back

=cut

print "check '不'\n";
my @ok_bu;
$ok_bu[4][0]=
$ok_bu[2][0]=
$ok_bu[4][1]=
$ok_bu[4][2]=
$ok_bu[4][3]=
$ok_bu[2][4]=1;
for my $ci (sort grep /不/, keys %ciyin) {
    my $len = length $ci;
    for my $yinlist(@{$ciyin{$ci}}) {
	my @yin = @$yinlist;
	my @num = map {
	    my $lastbpmf = substr $_, -1, 1;
	    $note{$lastbpmf} || 1
	} @yin[0 .. $len-1];

	for my$i(0 .. $len-1) {
	    if(substr($ci, $i, 1) eq '不') {
		if(!$ok_bu[$num[$i]][$num[$i+1]]) {
		    print "$ci\t", @{$yinlist}[0..$len-1], "\t# 不\n";
		}
	    }
	}
    }
}
print "\n";

=pod

=item list traditional-simplified ambiguous ci

當兩個詞進行簡繁轉換結果相同, 有可能兩個詞的詞義相同, 
為異體字或簡化字關係. 需人工檢視.

=cut

print "list traditional-simplified ambiguous ci\n";
use Encode::HanConvert;
for my $yinstr (sort grep { 
	@{$yinstr2ci{$_}}>1 
	&&
	length $yinstr2ci{$_}[0] > 1
    } keys %yinstr2ci) {

    my @entry = sort {
	$b->[1] <=> $a->[1]
    } map {
	my $ci = $_;
	my $line = $ciyinstr2line{$ci,$yinstr};
	my $freq = $freq[$line];
	[ $ci, $freq, $line ],
    } @{$yinstr2ci{$yinstr}};

    my %simpci;
    for (@entry) {
	my $simp = trad_to_simp($_->[0]);
	$simpci{$simp}++;
    }
    for my $simp(grep $simpci{$_}>1, keys %simpci) {
	my @diff = grep {
	    !/[
	    台臺檯 證証 癡痴 濕溼 
	    污汙 曬晒 鑑鑒 欲慾 嘆歎 
	    你妳 鋪舖 灑洒 豔艷 體体
	    佔占 伙夥 布佈 
	    唇脣 秘祕
	    砲炮 表錶 槍鎗
	    薦荐 並併并 注註 嘗嚐
	    #
	    周週 尺呎 布佈 仿倣 藥葯 雕彫
	    堤隄 鎚錘 嚥咽 燄焰 念唸 暖煖
	    妝粧 傭佣 了瞭 雇僱 掛挂 虫蟲
	    坑阬 誇夸 回迴 匯彙 岩巖 饑肌
	    寸吋 裡裏 弦絃 閒閑 扣釦 升昇
	    櫃柜 吃喫 沖衝 蹟跡 搥捶 夫伕
	    衝沖 屍尸 蝨虱 莊庄 才纔 毀燬
	    斂歛 鏽銹 剩賸 餚肴 蘇甦 兇凶
	    挽輓 禦御
	    ]/x
	} ci_diff(map $_->[0], 
	    grep $simp eq trad_to_simp($_->[0]),
	    @entry);
	
	next if @diff == 0;

	for (@entry) {
	    next unless $simp eq trad_to_simp($_->[0]);
	    print "$_->[0]\t$_->[1]\t$yinstr\t# ",trad_to_simp($_->[0]),"\n";
	}
	print "\n";
    }
}

=pod

=item list all ambiguous ci with same yin

列出同音詞, 並依詞頻順序列出. 可藉此抓出別字. 同時可檢視破音字的詞頻是否異常, 藉此修正同音詞的第一優先選詞.

=cut

print "list all ambiguous ci with same yin\n";
for my $yinstr (sort {
	length $yinstr2ci{$a}[0] <=> length $yinstr2ci{$b}[0] ||
	$a cmp $b
    } grep { 
	@{$yinstr2ci{$_}}>1 
    } keys %yinstr2ci) {

    my @yin = split / /, $yinstr;
    my @entry = sort {
	$b->[1] <=> $a->[1]
    } map {
	my $ci = $_;
	my $line = $ciyinstr2line{$ci,$yinstr};
	my $freq = $freq[$line];
	[ $ci, $freq, $line ],
    } @{$yinstr2ci{$yinstr}};

    if (@yin == 1) {
	my $majoryin = majorziyin($entry[0][0]);
	@entry = @entry[0 .. 4] if @entry > 5;

	next if $majoryin eq $yinstr;
	next if $entry[1][1] <= 1;

	for (@entry) {
	    my($zi, $freq, $line) = @$_;
	    #print "$line, ";
	    if ($entry[0][0] eq $_->[0]) {
		print "$zi\t$freq\t$yinstr # major yin: $majoryin\n";
	    } else {
		print "$zi\t$freq\t$yinstr\n";
	    }
	}
    } else {
	my @diff = grep {
	    !/[
	    台臺檯 唯惟 證証 癡痴 詞辭 濕溼 
	    沉沈 污汙 曬晒 分份 鑑鑒 欲慾 嘆歎 
	    你妳 他她 鋪舖 灑洒 豔艷 煙菸 體体
	    佔占 伙夥 布佈 甚什 
	    番蕃 帳賬 唇脣 秘祕
	    的地得 砲炮 表錶 槍鎗
	    ]/x
	} ci_diff(map $_->[0], @entry);

	next if @diff == 0;

	for (@entry) {
	    my($ci, $freq, $line) = @$_;
	    #print "$line, ";
	    print "$ci\t$freq\t$yinstr\n";
	}
    }
    print "\n";
}
print "\n";

print "done\n";

=pod

=back

=cut

sub ci_diff {
    my (@ci) = @_;
    my @diff;
    for my $i(0 .. length $ci[0] -1) {
	my %zi = ();
	for (@ci) {
	    my $zi = substr $_, $i, 1;
	    $zi{$zi}++;
	}
	push @diff, keys %zi if scalar keys %zi > 1;
    }
    return @diff;
}

sub majorziyin {
    my($zi) = @_;
    my @entry = sort {
	$b->[1] <=> $a->[1]
    } map {
	my $yin = $_;
	my $freq = $ziyinfreq{$zi}{$yin};
	#print "$zi, $yin, $freq\n";
	[ $yin, $freq ]
    } keys %{$ziyin{$zi}};

    return $entry[0][0];
}

sub wrong {
    my($lineno, $msg) = @_;
    print $rawdata[$lineno], "\t# ", $msg, "\n";
}

=pod

由於程式輸出並非都是有誤的部份, 因此建議的使用方式是先完整檢視過一次, 以後只要比較新版 tsi.src 相異的部份即可.
如此便能很快地找出 tsi.src 中明顯的問題.

=head1 AUTHOR

Kuang-che Wu

=cut

