// Define the `main` function

const proxyName = "PROXY";

function main(params) {
  if (!params.proxies) return params;
  
  // Basic
  overwriteBasicOptions(params);

  // DNS
  overwriteDNSOptions(params);

  // Rules
  overwtiteRulesOptions(params);

  // PROXY
  overwriteProxyOptions(params);
  
  return params;
}

// ==============================================================================
// =================Basic Options=================
// ==============================================================================
// Overwrite basic options for the configuration
function overwriteBasicOtherOptions(params) {
  const otherOptions = {
    "mixed-port": {{ keepassxcAttribute "Applications/clash-verge" "mixed-port" -}},
    "allow-lan": true,
    mode: "rule",
    "log-level": "warning",
    ipv6: true,
    "find-process-mode": "strict",
    profile: {
      "store-selected": true,
      "store-fake-ip": true,
    },
    "unified-delay": true,
    "tcp-concurrent": true,
    "global-client-fingerprint": "chrome",
    sniffer: {
      enable: true,
      sniff: {
        HTTP: {
          ports: [80, "8080-8880"],
          "override-destination": true,
        },
        TLS: {
          ports: [443, 8443],
        },
        QUIC: {
          ports: [443, 8443],
        },
      },
      // TODO: Why we need to skip them
      "skip-domain": [
        "Mijia Cloud",
        "+.push.apple.com",
        "+.wechat.com",
        "+.qpic.cn",
        "+.qq.com",
        "+.wechatapp.com",
        "+.vivox.com",
        "*.nju.edu.cn",
        "+.oray.com",
        "+.sunlogin.net",
      ],
      "skip-dst-address": [
        "223.5.5.5/32",
        "223.6.6.6/32",
        "1.12.12.12/32",
        "120.53.53.53/32",
      ],
    },
  };
  Object.keys(otherOptions).forEach((key) => {
    params[key] = otherOptions[key];
  });
}
// Overwrite Hosts
function overwriteHosts(params) {
  const hosts = {
    "dns.alidns.com": [
      "223.5.5.5",
      "223.6.6.6",
      "2400:3200:baba::1",
      "2400:3200::1",
    ],
    "doh.pub": ["120.53.53.53", "1.12.12.12"],
    "cdn.jsdelivr.net": ["cdn.jsdelivr.net.cdn.cloudflare.net"],
  };
  params.hosts = hosts;
}
// Overwrite Geodata
function overwriteGeodata(params) {
  // GitHub 加速前缀
  const githubPrefix = "";

  // GEO 数据 GitHub 资源原始下载地址
  const rawGeoxURLs = {
    geoip:
      "https://cdn.jsdelivr.net/gh/MetaCubeX/meta-rules-dat@release/geoip.dat",
    geosite:
      "https://cdn.jsdelivr.net/gh/MetaCubeX/meta-rules-dat@release/geosite.dat",
    // mmdb: "https://github.com/MetaCubeX/meta-rules-dat/releases/download/latest/country-lite.mmdb",
    asn: "https://cdn.jsdelivr.net/gh/MetaCubeX/meta-rules-dat@release/GeoLite2-ASN.mmdb",
  };

  // 生成带有加速前缀的 GEO 数据资源对象
  const accelURLs = Object.fromEntries(
    Object.entries(rawGeoxURLs).map(([key, githubUrl]) => [
      key,
      `${githubPrefix}${githubUrl}`,
    ])
  );

  const otherOptions = {
    "geodata-mode": true,
    "geo-auto-update": true, 
    "geo-update-interval": 24,
    "geox-url": accelURLs,
  };

  Object.keys(otherOptions).forEach((key) => {
    params[key] = otherOptions[key];
  });
}
// Overwrite Tun Options
function overwriteTunnel(params) {
  const tunnelOptions = {
    enable: true,
    stack: "system",
    device: "Mihomo",
    "dns-hijack": ["any:53", "tcp://any:53"],
    "auto-route": true,
    "auto-detect-interface": true,
    "strict-route": true,
    // 根据自己环境来看要排除哪些网段
    "route-exclude-address": ["192.168.194.0/24"],
  };
  params.tun = { ...tunnelOptions };
}

// Overwite Basic Options
function overwriteBasicOptions(params) {
  overwriteBasicOtherOptions(params); // Overwrite Basic Other Options
  overwriteHosts(params); // Overwrite Hosts
  overwriteGeodata(params); // Overwrite Geodata
  overwriteTunnel(params); // Overwrite Tunnel
}


// ==============================================================================
// ================DNS Options=================
// ==============================================================================
// Overwrite DNS settings for the configuration
function overwriteDns(params) {
  const defaultNameservers = [
    "system",
    "223.5.5.5", // Ali
    // "1.12.12.12", // DoT DoH
    // "119.29.29.29", // Tencent
    // "180.184.1.1", // 字节
  ];
  const Nameservers = [
    // "system", // System
    "https://223.5.5.5/dns-query",
    "https://doh.pub/dns-query",
  ];
  const proxyNameservers = [
    {{ keepassxcAttribute "Applications/clash-verge" "DoH-alidns" | printf "%q" -}},
    "https://223.5.5.5/dns-query",
    "https://doh.pub/dns-query",
    "https://1.0.0.1/dns-query",
    "https://1.1.1.1/dns-query",
  ];

  const dnsOptions = {
    enable: true,
    "prefer-h3": false,
    ipv6: false,
    "respect-rules": true,
    "enhanced-mode": "fake-ip",
    "fake-ip-range": "198.18.0.1/16",
    // "default-nameserver": defaultNameservers, // 用于解析其他 DNS 服务器、和节点的域名，必须为 IP, 可为加密 DNS。注意这个只用来解析节点和其他的 dns，其他网络请求不归他管
    "proxy-server-nameserver": proxyNameservers, // 匹配路由规则后的DNS解析服务器，仅解析代理节点的域名
    nameserver: Nameservers, // 其他网络请求都归他管
  };
  params.dns = { ...dnsOptions };
}
// Overwrite DNS FakeIP Filter
function overwriteFakeIpFilter(params) {
  const fakeIpFilter = [
    "+.+m2m",
    "+.$injections.adguard.org",
    "+.$local.adguard.org",
    "+.+bogon",
    "+.+lan",
    "*.local",
    "+.+localdomain",
    "+.home.arpa",
    "+.gitv.tv",
    "+.docker.io",
    "+.miwifi.com",
    "+.safebrowsing.apple",
    "Mijia Cloud",
    "time.*.com",
    "time.*.gov",
    "time.*.edu.cn",
    "time.*.apple.com",
    "time-ios.apple.com",
    "time1.*.com",
    "time2.*.com",
    "time3.*.com",
    "time4.*.com",
    "time5.*.com",
    "time6.*.com",
    "time7.*.com",
    "ntp.*.com",
    "ntp1.*.com",
    "ntp2.*.com",
    "ntp3.*.com",
    "ntp4.*.com",
    "ntp5.*.com",
    "ntp6.*.com",
    "ntp7.*.com",
    "*.time.edu.cn",
    "*.ntp.org.cn",
    "+.pool.ntp.org",
    "*.nju.edu.cn",
    "time1.cloud.tencent.com",
    "+.10.in-addr.arpa",
    "+.16.172.in-addr.arpa",
    "+.17.172.in-addr.arpa",
    "+.18.172.in-addr.arpa",
    "+.19.172.in-addr.arpa",
    "+.20.172.in-addr.arpa",
    "+.21.172.in-addr.arpa",
    "+.22.172.in-addr.arpa",
    "+.23.172.in-addr.arpa",
    "+.24.172.in-addr.arpa",
    "+.25.172.in-addr.arpa",
    "+.26.172.in-addr.arpa",
    "+.27.172.in-addr.arpa",
    "+.28.172.in-addr.arpa",
    "+.29.172.in-addr.arpa",
    "+.30.172.in-addr.arpa",
    "+.31.172.in-addr.arpa",
    "+.168.192.in-addr.arpa",
    "+.254.169.in-addr.arpa",
    "dns.msftncsi.com",
    "*.srv.nintendo.net",
    "*.stun.playstation.net",
    "xbox.*.microsoft.com",
    "*.xboxlive.com",
    "*.turn.twilio.com",
    "*.stun.twilio.com",
    "stun.syncthing.net",
    "stun.*",
  ];
  params.dns["fake-ip-filter"] = fakeIpFilter;
}
// Overwrite DNS Nameserver Policy
function overwriteNameserverPolicy(params) {
  const nameserverPolicy = {
    "dns.alidns.com": "quic://223.5.5.5:853",
    "doh.pub": "https://1.12.12.12/dns-query",
    "doh.360.cn": "101.198.198.198",
    "+.nju.edu.cn": "10.60.1.2",
    "+.uc.cn": "quic://dns.alidns.com:853",
    "+.alibaba.com": "quic://dns.alidns.com:853",
    "*.alicdn.com": "quic://dns.alidns.com:853",
    "*.ialicdn.com": "quic://dns.alidns.com:853",
    "*.myalicdn.com": "quic://dns.alidns.com:853",
    "*.alidns.com": "quic://dns.alidns.com:853",
    "*.aliimg.com": "quic://dns.alidns.com:853",
    "+.aliyun.com": "quic://dns.alidns.com:853",
    "*.aliyuncs.com": "quic://dns.alidns.com:853",
    "*.alikunlun.com": "quic://dns.alidns.com:853",
    "*.alikunlun.net": "quic://dns.alidns.com:853",
    "*.cdngslb.com": "quic://dns.alidns.com:853",
    "+.alipay.com": "quic://dns.alidns.com:853",
    "+.alipay.cn": "quic://dns.alidns.com:853",
    "+.alipay.com.cn": "quic://dns.alidns.com:853",
    "*.alipayobjects.com": "quic://dns.alidns.com:853",
    "+.alibaba-inc.com": "quic://dns.alidns.com:853",
    "*.alibabausercontent.com": "quic://dns.alidns.com:853",
    "*.alibabadns.com": "quic://dns.alidns.com:853",
    "+.alibabachengdun.com": "quic://dns.alidns.com:853",
    "+.alicloudccp.com": "quic://dns.alidns.com:853",
    "+.alipan.com": "quic://dns.alidns.com:853",
    "+.aliyundrive.com": "quic://dns.alidns.com:853",
    "+.aliyundrive.net": "quic://dns.alidns.com:853",
    "+.cainiao.com": "quic://dns.alidns.com:853",
    "+.cainiao.com.cn": "quic://dns.alidns.com:853",
    "+.cainiaoyizhan.com": "quic://dns.alidns.com:853",
    "+.guoguo-app.com": "quic://dns.alidns.com:853",
    "+.etao.com": "quic://dns.alidns.com:853",
    "+.yitao.com": "quic://dns.alidns.com:853",
    "+.1688.com": "quic://dns.alidns.com:853",
    "+.amap.com": "quic://dns.alidns.com:853",
    "+.gaode.com": "quic://dns.alidns.com:853",
    "+.autonavi.com": "quic://dns.alidns.com:853",
    "+.dingtalk.com": "quic://dns.alidns.com:853",
    "+.mxhichina.com": "quic://dns.alidns.com:853",
    "+.soku.com": "quic://dns.alidns.com:853",
    "+.tb.cn": "quic://dns.alidns.com:853",
    "+.taobao.com": "quic://dns.alidns.com:853",
    "*.taobaocdn.com": "quic://dns.alidns.com:853",
    "*.tbcache.com": "quic://dns.alidns.com:853",
    "+.tmall.com": "quic://dns.alidns.com:853",
    "+.goofish.com": "quic://dns.alidns.com:853",
    "+.xiami.com": "quic://dns.alidns.com:853",
    "+.xiami.net": "quic://dns.alidns.com:853",
    "*.ykimg.com": "quic://dns.alidns.com:853",
    "+.youku.com": "quic://dns.alidns.com:853",
    "+.tudou.com": "quic://dns.alidns.com:853",
    "*.cibntv.net": "quic://dns.alidns.com:853",
    "+.ele.me": "quic://dns.alidns.com:853",
    "*.elemecdn.com": "quic://dns.alidns.com:853",
    "+.feizhu.com": "quic://dns.alidns.com:853",
    "+.taopiaopiao.com": "quic://dns.alidns.com:853",
    "+.fliggy.com": "quic://dns.alidns.com:853",
    "+.koubei.com": "quic://dns.alidns.com:853",
    "+.mybank.cn": "quic://dns.alidns.com:853",
    "+.mmstat.com": "quic://dns.alidns.com:853",
    "+.uczzd.cn": "quic://dns.alidns.com:853",
    "+.iconfont.cn": "quic://dns.alidns.com:853",
    "+.freshhema.com": "quic://dns.alidns.com:853",
    "+.hemamax.com": "quic://dns.alidns.com:853",
    "+.hemaos.com": "quic://dns.alidns.com:853",
    "+.hemashare.cn": "quic://dns.alidns.com:853",
    "+.shyhhema.com": "quic://dns.alidns.com:853",
    "+.sm.cn": "quic://dns.alidns.com:853",
    "+.npmmirror.com": "quic://dns.alidns.com:853",
    "+.alios.cn": "quic://dns.alidns.com:853",
    "+.wandoujia.com": "quic://dns.alidns.com:853",
    "+.aligames.com": "quic://dns.alidns.com:853",
    "+.25pp.com": "quic://dns.alidns.com:853",
    "*.aliapp.org": "quic://dns.alidns.com:853",
    "+.tanx.com": "quic://dns.alidns.com:853",
    "+.hellobike.com": "quic://dns.alidns.com:853",
    "*.hichina.com": "quic://dns.alidns.com:853",
    "*.yunos.com": "quic://dns.alidns.com:853",
    "*.nlark.com": "quic://dns.alidns.com:853",
    "*.yuque.com": "quic://dns.alidns.com:853",
    "upos-sz-mirrorali.bilivideo.com": "quic://dns.alidns.com:853",
    "upos-sz-estgoss.bilivideo.com": "quic://dns.alidns.com:853",
    "ali-safety-video.acfun.cn": "quic://dns.alidns.com:853",
    "+.grok.com": "https://doh.pub/dns-query",
    "+.linux.do": "https://doh.pub/dns-query",
    "download.pytorch.org":  "https://doh.pub/dns-query",
    "*.qcloud.com": "https://doh.pub/dns-query",
    "*.gtimg.cn": "https://doh.pub/dns-query",
    "*.gtimg.com": "https://doh.pub/dns-query",
    "*.gtimg.com.cn": "https://doh.pub/dns-query",
    "*.gdtimg.com": "https://doh.pub/dns-query",
    "*.idqqimg.com": "https://doh.pub/dns-query",
    "*.udqqimg.com": "https://doh.pub/dns-query",
    "*.igamecj.com": "https://doh.pub/dns-query",
    "+.myapp.com": "https://doh.pub/dns-query",
    "*.myqcloud.com": "https://doh.pub/dns-query",
    "+.dnspod.com": "https://doh.pub/dns-query",
    "*.qpic.cn": "https://doh.pub/dns-query",
    "*.qlogo.cn": "https://doh.pub/dns-query",
    "+.qq.com": "https://doh.pub/dns-query",
    "+.qq.com.cn": "https://doh.pub/dns-query",
    "*.qqmail.com": "https://doh.pub/dns-query",
    "+.qzone.com": "https://doh.pub/dns-query",
    "*.tencent-cloud.net": "https://doh.pub/dns-query",
    "*.tencent-cloud.com": "https://doh.pub/dns-query",
    "+.tencent.com": "https://doh.pub/dns-query",
    "+.tencent.com.cn": "https://doh.pub/dns-query",
    "+.tencentmusic.com": "https://doh.pub/dns-query",
    "+.weixinbridge.com": "https://doh.pub/dns-query",
    "+.weixin.com": "https://doh.pub/dns-query",
    "+.weiyun.com": "https://doh.pub/dns-query",
    "+.soso.com": "https://doh.pub/dns-query",
    "+.sogo.com": "https://doh.pub/dns-query",
    "+.sogou.com": "https://doh.pub/dns-query",
    "*.sogoucdn.com": "https://doh.pub/dns-query",
    "*.roblox.cn": "https://doh.pub/dns-query",
    "+.robloxdev.cn": "https://doh.pub/dns-query",
    "+.wegame.com": "https://doh.pub/dns-query",
    "+.wegame.com.cn": "https://doh.pub/dns-query",
    "+.wegameplus.com": "https://doh.pub/dns-query",
    "+.cdn-go.cn": "https://doh.pub/dns-query",
    "*.tencentcs.cn": "https://doh.pub/dns-query",
    "*.qcloudimg.com": "https://doh.pub/dns-query",
    "+.dnspod.cn": "https://doh.pub/dns-query",
    "+.anticheatexpert.com": "https://doh.pub/dns-query",
    "url.cn": "https://doh.pub/dns-query",
    "*.qlivecdn.com": "https://doh.pub/dns-query",
    "*.tcdnlive.com": "https://doh.pub/dns-query",
    "*.dnsv1.com": "https://doh.pub/dns-query",
    "*.smtcdns.net": "https://doh.pub/dns-query",
    "+.coding.net": "https://doh.pub/dns-query",
    "*.codehub.cn": "https://doh.pub/dns-query",
    "tx-safety-video.acfun.cn": "https://doh.pub/dns-query",
    "acg.tv": "https://doh.pub/dns-query",
    "b23.tv": "https://doh.pub/dns-query",
    "+.bilibili.cn": "https://doh.pub/dns-query",
    "+.bilibili.com": "https://doh.pub/dns-query",
    "*.acgvideo.com": "https://doh.pub/dns-query",
    "*.bilivideo.com": "https://doh.pub/dns-query",
    "*.bilivideo.cn": "https://doh.pub/dns-query",
    "*.bilivideo.net": "https://doh.pub/dns-query",
    "*.hdslb.com": "https://doh.pub/dns-query",
    "*.biliimg.com": "https://doh.pub/dns-query",
    "*.biliapi.com": "https://doh.pub/dns-query",
    "*.biliapi.net": "https://doh.pub/dns-query",
    "+.biligame.com": "https://doh.pub/dns-query",
    "*.biligame.net": "https://doh.pub/dns-query",
    "+.bilicomic.com": "https://doh.pub/dns-query",
    "+.bilicomics.com": "https://doh.pub/dns-query",
    "*.bilicdn1.com": "https://doh.pub/dns-query",
    "+.mi.com": "https://doh.pub/dns-query",
    "+.duokan.com": "https://doh.pub/dns-query",
    "*.mi-img.com": "https://doh.pub/dns-query",
    "*.mi-idc.com": "https://doh.pub/dns-query",
    "*.xiaoaisound.com": "https://doh.pub/dns-query",
    "*.xiaomixiaoai.com": "https://doh.pub/dns-query",
    "*.mi-fds.com": "https://doh.pub/dns-query",
    "*.mifile.cn": "https://doh.pub/dns-query",
    "*.mijia.tech": "https://doh.pub/dns-query",
    "+.miui.com": "https://doh.pub/dns-query",
    "+.xiaomi.com": "https://doh.pub/dns-query",
    "+.xiaomi.cn": "https://doh.pub/dns-query",
    "+.xiaomi.net": "https://doh.pub/dns-query",
    "+.xiaomiev.com": "https://doh.pub/dns-query",
    "+.xiaomiyoupin.com": "https://doh.pub/dns-query",
    "+.bytedance.com": "180.184.2.2",
    "*.bytecdn.cn": "180.184.2.2",
    "*.volccdn.com": "180.184.2.2",
    "*.toutiaoimg.com": "180.184.2.2",
    "*.toutiaoimg.cn": "180.184.2.2",
    "*.toutiaostatic.com": "180.184.2.2",
    "*.toutiaovod.com": "180.184.2.2",
    "*.toutiaocloud.com": "180.184.2.2",
    "+.toutiaopage.com": "180.184.2.2",
    "+.feiliao.com": "180.184.2.2",
    "+.iesdouyin.com": "180.184.2.2",
    "*.pstatp.com": "180.184.2.2",
    "+.snssdk.com": "180.184.2.2",
    "*.bytegoofy.com": "180.184.2.2",
    "+.toutiao.com": "180.184.2.2",
    "+.feishu.cn": "180.184.2.2",
    "+.feishu.net": "180.184.2.2",
    "*.feishucdn.com": "180.184.2.2",
    "*.feishupkg.com": "180.184.2.2",
    "+.douyin.com": "180.184.2.2",
    "*.douyinpic.com": "180.184.2.2",
    "*.douyinstatic.com": "180.184.2.2",
    "*.douyincdn.com": "180.184.2.2",
    "*.douyinliving.com": "180.184.2.2",
    "*.douyinvod.com": "180.184.2.2",
    "+.huoshan.com": "180.184.2.2",
    "*.huoshanstatic.com": "180.184.2.2",
    "+.huoshanzhibo.com": "180.184.2.2",
    "+.ixigua.com": "180.184.2.2",
    "*.ixiguavideo.com": "180.184.2.2",
    "*.ixgvideo.com": "180.184.2.2",
    "*.byted-static.com": "180.184.2.2",
    "+.volces.com": "180.184.2.2",
    "+.baike.com": "180.184.2.2",
    "*.zjcdn.com": "180.184.2.2",
    "*.zijieapi.com": "180.184.2.2",
    "+.feelgood.cn": "180.184.2.2",
    "*.bytetcc.com": "180.184.2.2",
    "*.bytednsdoc.com": "180.184.2.2",
    "*.byteimg.com": "180.184.2.2",
    "*.byteacctimg.com": "180.184.2.2",
    "*.ibytedapm.com": "180.184.2.2",
    "+.oceanengine.com": "180.184.2.2",
    "*.edge-byted.com": "180.184.2.2",
    "*.volcvideo.com": "180.184.2.2",
    "+.91.com": "180.76.76.76",
    "+.hao123.com": "180.76.76.76",
    "+.baidu.cn": "180.76.76.76",
    "+.baidu.com": "180.76.76.76",
    "+.iqiyi.com": "180.76.76.76",
    "*.iqiyipic.com": "180.76.76.76",
    "*.baidubce.com": "180.76.76.76",
    "*.bcelive.com": "180.76.76.76",
    "*.baiducontent.com": "180.76.76.76",
    "*.baidustatic.com": "180.76.76.76",
    "*.bdstatic.com": "180.76.76.76",
    "*.bdimg.com": "180.76.76.76",
    "*.bcebos.com": "180.76.76.76",
    "*.baidupcs.com": "180.76.76.76",
    "*.baidubcr.com": "180.76.76.76",
    "*.yunjiasu-cdn.net": "180.76.76.76",
    "+.tieba.com": "180.76.76.76",
    "+.xiaodutv.com": "180.76.76.76",
    "*.shifen.com": "180.76.76.76",
    "*.jomodns.com": "180.76.76.76",
    "*.bdydns.com": "180.76.76.76",
    "*.jomoxc.com": "180.76.76.76",
    "*.duapp.com": "180.76.76.76",
    "*.antpcdn.com": "180.76.76.76",
    "upos-sz-mirrorbd.bilivideo.com": "180.76.76.76",
    "upos-sz-mirrorbos.bilivideo.com": "180.76.76.76",
    "*.qhimg.com": "https://doh.360.cn/dns-query",
    "*.qhimgs.com": "https://doh.360.cn/dns-query",
    "*.qhimgs?.com": "https://doh.360.cn/dns-query",
    "*.qhres.com": "https://doh.360.cn/dns-query",
    "*.qhres2.com": "https://doh.360.cn/dns-query",
    "*.qhmsg.com": "https://doh.360.cn/dns-query",
    "*.qhstatic.com": "https://doh.360.cn/dns-query",
    "*.qhupdate.com": "https://doh.360.cn/dns-query",
    "*.qihucdn.com": "https://doh.360.cn/dns-query",
    "+.360.com": "https://doh.360.cn/dns-query",
    "+.360.cn": "https://doh.360.cn/dns-query",
    "+.360.net": "https://doh.360.cn/dns-query",
    "+.360safe.com": "https://doh.360.cn/dns-query",
    "*.360tpcdn.com": "https://doh.360.cn/dns-query",
    "+.360os.com": "https://doh.360.cn/dns-query",
    "*.360webcache.com": "https://doh.360.cn/dns-query",
    "+.360kuai.com": "https://doh.360.cn/dns-query",
    "+.so.com": "https://doh.360.cn/dns-query",
    "+.haosou.com": "https://doh.360.cn/dns-query",
    "+.yunpan.cn": "https://doh.360.cn/dns-query",
    "+.yunpan.com": "https://doh.360.cn/dns-query",
    "+.yunpan.com.cn": "https://doh.360.cn/dns-query",
    "*.qh-cdn.com": "https://doh.360.cn/dns-query",
    "+.baomitu.com": "https://doh.360.cn/dns-query",
    "+.qiku.com": "https://doh.360.cn/dns-query",
    "+.securelogin.com.cn": ["system://", "system", "dhcp://system"],
    "captive.apple.com": ["system://", "system", "dhcp://system"],
    "hotspot.cslwifi.com": ["system://", "system", "dhcp://system"],
    "*.m2m": ["system://", "system", "dhcp://system"],
    "injections.adguard.org": ["system://", "system", "dhcp://system"],
    "local.adguard.org": ["system://", "system", "dhcp://system"],
    "*.bogon": ["system://", "system", "dhcp://system"],
    "*.home": ["system://", "system", "dhcp://system"],
    "instant.arubanetworks.com": ["system://", "system", "dhcp://system"],
    "setmeup.arubanetworks.com": ["system://", "system", "dhcp://system"],
    "router.asus.com": ["system://", "system", "dhcp://system"],
    "repeater.asus.com": ["system://", "system", "dhcp://system"],
    "+.asusrouter.com": ["system://", "system", "dhcp://system"],
    "+.routerlogin.net": ["system://", "system", "dhcp://system"],
    "+.routerlogin.com": ["system://", "system", "dhcp://system"],
    "+.tplinkwifi.net": ["system://", "system", "dhcp://system"],
    "+.tplogin.cn": ["system://", "system", "dhcp://system"],
    "+.tplinkap.net": ["system://", "system", "dhcp://system"],
    "+.tplinkmodem.net": ["system://", "system", "dhcp://system"],
    "+.tplinkplclogin.net": ["system://", "system", "dhcp://system"],
    "+.tplinkrepeater.net": ["system://", "system", "dhcp://system"],
    "*.ui.direct": ["system://", "system", "dhcp://system"],
    unifi: ["system://", "system", "dhcp://system"],
    "*.huaweimobilewifi.com": ["system://", "system", "dhcp://system"],
    "*.router": ["system://", "system", "dhcp://system"],
    "aterm.me": ["system://", "system", "dhcp://system"],
    "console.gl-inet.com": ["system://", "system", "dhcp://system"],
    "homerouter.cpe": ["system://", "system", "dhcp://system"],
    "mobile.hotspot": ["system://", "system", "dhcp://system"],
    "ntt.setup": ["system://", "system", "dhcp://system"],
    "pi.hole": ["system://", "system", "dhcp://system"],
    "*.plex.direct": ["system://", "system", "dhcp://system"],
    "*.lan": ["system://", "system", "dhcp://system"],
    "*.localdomain": ["system://", "system", "dhcp://system"],
    "+.home.arpa": ["system://", "system", "dhcp://system"],
    "+.10.in-addr.arpa": ["system://", "system", "dhcp://system"],
    "+.16.172.in-addr.arpa": ["system://", "system", "dhcp://system"],
    "+.17.172.in-addr.arpa": ["system://", "system", "dhcp://system"],
    "+.18.172.in-addr.arpa": ["system://", "system", "dhcp://system"],
    "+.19.172.in-addr.arpa": ["system://", "system", "dhcp://system"],
    "+.20.172.in-addr.arpa": ["system://", "system", "dhcp://system"],
    "+.21.172.in-addr.arpa": ["system://", "system", "dhcp://system"],
    "+.22.172.in-addr.arpa": ["system://", "system", "dhcp://system"],
    "+.23.172.in-addr.arpa": ["system://", "system", "dhcp://system"],
    "+.24.172.in-addr.arpa": ["system://", "system", "dhcp://system"],
    "+.25.172.in-addr.arpa": ["system://", "system", "dhcp://system"],
    "+.26.172.in-addr.arpa": ["system://", "system", "dhcp://system"],
    "+.27.172.in-addr.arpa": ["system://", "system", "dhcp://system"],
    "+.28.172.in-addr.arpa": ["system://", "system", "dhcp://system"],
    "+.29.172.in-addr.arpa": ["system://", "system", "dhcp://system"],
    "+.30.172.in-addr.arpa": ["system://", "system", "dhcp://system"],
    "+.31.172.in-addr.arpa": ["system://", "system", "dhcp://system"],
    "+.168.192.in-addr.arpa": ["system://", "system", "dhcp://system"],
    "+.254.169.in-addr.arpa": ["system://", "system", "dhcp://system"],
  };
  params.dns["nameserver-policy"] = nameserverPolicy;
}

function overwriteDNSOptions(params) {
  overwriteDns(params); // Overwrite DNS Options
  overwriteFakeIpFilter(params); // Overwrite DNS FakeIP Filter
  overwriteNameserverPolicy(params); // Overwrite DNS Nameserver Policy
}

// ==============================================================================
// ===============Rules Options===============================
// ==============================================================================
function getRuleProviders() {
  // Reject Rules
  const reject_rules = {
    reject_non_ip_no_drop: {
      type: "http",
      behavior: "classical",
      url: "https://ruleset.skk.moe/Clash/non_ip/reject-no-drop.txt",
      interval: 43200,
      format: "text",
      proxy: proxyName,
      path: "./sukkaw_ruleset/reject_non_ip_no_drop.txt", 
    },
    reject_non_ip_drop: {
      type: "http",
      behavior: "classical",
      url: "https://ruleset.skk.moe/Clash/non_ip/reject-drop.txt",
      interval: 43200,
      format: "text",
      proxy: proxyName,
      path: "./sukkaw_ruleset/reject_non_ip_drop.txt", 
    },
    reject_non_ip: {
      type: "http",
      behavior: "classical",
      url: "https://ruleset.skk.moe/Clash/non_ip/reject.txt",
      interval: 43200,
      format: "text",
      proxy: proxyName,
      path: "./sukkaw_ruleset/reject_non_ip.txt", 
    },
    reject_domainset: {
      type: "http",
      behavior: "domain",
      url: "https://ruleset.skk.moe/Clash/domainset/reject.txt",
      interval: 43200,
      format: "text",
      proxy: proxyName,
      path: "./sukkaw_ruleset/reject_domainset.txt", 
    },
    reject_ip: {
      type: "http",
      behavior: "classical",
      url: "https://ruleset.skk.moe/Clash/ip/reject.txt",
      interval: 43200,
      format: "text",
      proxy: proxyName,
      path: "./sukkaw_ruleset/reject_ip.txt", 
    },
    "category-public-tracker": {
      type: "http",
      behavior: "domain",
      url: "https://github.com/666OS/YYDS/raw/main/mihomo/rules/category-public-tracker.mrs",
      interval: 86400,
      format: "mrs",
      proxy: proxyName, 
      path: "./yyds/category-public-tracker.mrs"
    },
  };

  // CDN
  const cdn_rules = {
    cdn_domainset: {
      type: "http",
      behavior: "domain",
      url: "https://ruleset.skk.moe/Clash/domainset/cdn.txt",
      interval: 43200,
      format: "text",
      proxy: proxyName,
    },
    cdn_non_ip: {
      type: "http",
      behavior: "domain",
      url: "https://ruleset.skk.moe/Clash/non_ip/cdn.txt",
      interval: 43200,
      format: "text",
      proxy: proxyName,
    },
  };

  // speedtest
  const speedtest_rules = {
    speedtest: {
      type: "http",
      behavior: "domain",
      url: "https://ruleset.skk.moe/Clash/domainset/speedtest.txt",
      interval: 43200,
      format: "text",
      proxy: proxyName,
      path: "./sukkaw_ruleset/speedtest.txt", 
    },
  };

  // stream
  const stream_rules = {
    stream_non_ip: {
      type: "http",
      behavior: "classical",
      url: "https://ruleset.skk.moe/Clash/non_ip/stream.txt",
      interval: 43200,
      format: "text",
      proxy: proxyName,
      path: "./sukkaw_ruleset/stream_non_ip.txt"
    },
    stream_ip: {
      type: "http",
      behavior: "classical",
      url: "https://ruleset.skk.moe/Clash/ip/stream.txt",
      interval: 43200,
      format: "text",
      proxy: proxyName,
      path: "./sukkaw_ruleset/stream_ip.txt"
    },
    youtube: {
      type: "http",
      behavior: "domain",
      url: "https://github.com/666OS/YYDS/raw/main/mihomo/rules/youtube.mrs",
      interval: 86400,
      format: "mrs",
      proxy: proxyName,
      path: "./yyds/youtube.mrs"
    },
    spotify: {
      type: "http",
      behavior: "domain",
      url: "https://github.com/666OS/YYDS/raw/main/mihomo/rules/spotify.mrs",
      interval: 86400,
      format: "mrs",
      proxy: proxyName,
      path: "./yyds/spotify.mrs"
    },
    netflix: {
      type: "http",
      behavior: "domain",
      url: "https://github.com/666OS/YYDS/raw/main/mihomo/rules/netflix.mrs",
      interval: 86400,
      format: "mrs",
      proxy: proxyName, 
      path: "./yyds/netflix.mrs" 
    },
    disney: {
      type: "http",
      behavior: "domain",
      url: "https://github.com/666OS/YYDS/raw/main/mihomo/rules/disney.mrs",
      interval: 86400,
      format: "mrs",
      proxy: proxyName,
      path: "./yyds/disney.mrs"
    },
  };

  // ai
  const ai_rules = {
    ai_non_ip: {
      type: "http",
      behavior: "classical",
      url: "https://ruleset.skk.moe/Clash/non_ip/ai.txt",
      interval: 43200,
      format: "text",
      proxy: proxyName,
      path: "./sukkaw_ruleset/ai_non_ip.txt" 
    },
    openai: {
      type: "http",
      behavior: "domain",
      url: "https://github.com/666OS/YYDS/raw/main/mihomo/rules/openai.mrs",
      interval: 86400,
      format: "mrs",
      proxy: proxyName, 
      path: "./yyds/openai.mrs"
    },
  };

  // telegram
  const telegram_rules = {
    telegram: {
      type: "http",
      behavior: "domain",
      url: "https://github.com/666OS/YYDS/raw/main/mihomo/rules/telegram.mrs",
      interval: 86400,
      format: "mrs",
      proxy: proxyName,
      path: "./yyds/telegram.mrs"
    },
    telegram_non_ip: {
      type: "http",
      behavior: "classical",
      url: "https://ruleset.skk.moe/Clash/non_ip/telegram.txt",
      interval: 43200,
      format: "text",
      proxy: proxyName,
      path: "./sukkaw_ruleset/telegram_non_ip.txt"
    },
    telegram_ip: {
      type: "http",
      behavior: "classical",
      url: "https://ruleset.skk.moe/Clash/ip/telegram.txt",
      interval: 43200,
      format: "text",
      proxy: proxyName,
      path: "./sukkaw_ruleset/telegram_ip.txt"
    }
  };

  // apple
  const apple_rules = {
    "apple-cn": {
      type: "http",
      behavior: "domain",
      url: "https://github.com/666OS/YYDS/raw/main/mihomo/rules/apple-cn.mrs",
      interval: 86400,
      format: "mrs",
      proxy: proxyName,
      path: "./yyds/apple-cn.mrs"
    },
    apple: {
      type: "http",
      behavior: "domain",
      url: "https://github.com/666OS/YYDS/raw/main/mihomo/rules/apple.mrs",
      interval: 86400,
      format: "mrs",
      proxy: proxyName,
      path: "./yyds/apple.mrs"
    },
    apple_cdn: {
      type: "http",
      behavior: "domain",
      url: "https://ruleset.skk.moe/Clash/domainset/apple_cdn.txt",
      interval: 43200,
      format: "text",
      proxy: proxyName,
      path: "./sukkaw_ruleset/apple_cdn.txt"
    },
    apple_services: {
      type: "http",
      behavior: "classical",
      url: "https://ruleset.skk.moe/Clash/non_ip/apple_services.txt",
      interval: 43200,
      format: "text",
      proxy: proxyName,
      path: "./sukkaw_ruleset/apple_services.txt"
    },
    apple_cn_non_ip: {
      type: "http",
      behavior: "classical",
      url: "https://ruleset.skk.moe/Clash/non_ip/apple_cn.txt",
      interval: 43200,
      format: "text",
      proxy: proxyName,
      path: "./sukkaw_ruleset/apple_cn_non_ip.txt"
    }
  };

  // microsoft
  const microsoft_rules = {
    microsoft_cdn_non_ip: {
      type: "http",
      behavior: "classical",
      url: "https://ruleset.skk.moe/Clash/non_ip/microsoft_cdn.txt",
      interval: 43200,
      format: "text",
      proxy: proxyName,
      path: "./sukkaw_ruleset/microsoft_cdn_non_ip.txt"
    },
    microsoft_non_ip: {
      type: "http",
      behavior: "classical",
      url: "https://ruleset.skk.moe/Clash/non_ip/microsoft.txt",
      interval: 43200,
      format: "text",
      proxy: proxyName,
      path: "./sukkaw_ruleset/microsoft_non_ip.txt"
    },
    onedrive: {
      type: "http",
      behavior: "domain",
      url: "https://github.com/666OS/YYDS/raw/main/mihomo/rules/onedrive.mrs",
      interval: 86400,
      format: "mrs",
      proxy: proxyName,
      path: "./yyds/onedrive.mrs"
    },
    "microsoft@cn": {
      type: "http",
      behavior: "domain",
      url: "https://github.com/666OS/YYDS/raw/main/mihomo/rules/microsoft@cn.mrs",
      interval: 86400,
      format: "mrs",
      proxy: proxyName,
      path: "./yyds/microsoft@cn.mrs"
    },
    microsoft: {
      type: "http",
      behavior: "domain",
      url: "https://github.com/666OS/YYDS/raw/main/mihomo/rules/microsoft.mrs",
      interval: 86400,
      format: "mrs",
      proxy: proxyName,
      path: "./yyds/microsoft.mrs"
    },
  };

  // download
  const download_rules = {
    download_domainset: {
      type: "http",
      behavior: "domain",
      url: "https://ruleset.skk.moe/Clash/domainset/download.txt",
      interval: 43200,
      format: "text",
      proxy: proxyName,
      path: "./sukkaw_ruleset/download_domainset.txt", 
    },
    download_non_ip: {
      type: "http",
      behavior: "classical",
      url: "https://ruleset.skk.moe/Clash/non_ip/download.txt",
      interval: 43200,
      format: "text",
      proxy: proxyName,
      path: "./sukkaw_ruleset/download_non_ip.txt", 
    },
  };

  // private
  const private_rules = {
    private_domain: {
      type: "http",
      behavior: "domain",
      url: "https://github.com/666OS/YYDS/raw/main/mihomo/rules/private.mrs",
      interval: 86400,
      format: "mrs",
      proxy: proxyName,
      path: "./yyds/private.mrs"
    },
    lan_non_ip: {
      type: "http",
      behavior: "classical",
      url: "https://ruleset.skk.moe/Clash/non_ip/lan.txt",
      interval: 43200,
      format: "text",
      proxy: proxyName,
      path: "./sukkaw_ruleset/lan_non_ip.txt"
    },
    lan_ip: {
      type: "http",
      behavior: "classical",
      url: "https://ruleset.skk.moe/Clash/ip/lan.txt",
      interval: 43200,
      format: "text",
      proxy: proxyName,
      path: "./sukkaw_ruleset/lan_ip.txt"
    },
    private_ip: {
      type: "http",
      behavior: "ipcidr",
      url: "https://github.com/666OS/YYDS/raw/main/mihomo/rules/private_ip.mrs",
      interval: 86400,
      format: "mrs",
      proxy: proxyName,
      path: "./yyds/private_ip.mrs"
    },
  };
  // misc
  const misc_rules = {
    global_non_ip: {
      type: "http",
      behavior: "classical",
      url: "https://ruleset.skk.moe/Clash/non_ip/global.txt",
      interval: 43200,
      format: "text",
      proxy: proxyName,
      path: "./sukkaw_ruleset/global_non_ip.txt"
    },
    domestic_non_ip: {
      type: "http",
      behavior: "classical",
      url: "https://ruleset.skk.moe/Clash/non_ip/domestic.txt",
      interval: 43200,
      format: "text",
      proxy: proxyName,
      path: "./sukkaw_ruleset/domestic_non_ip.txt"
    },
    direct_non_ip: {
      type: "http",
      behavior: "classical",
      url: "https://ruleset.skk.moe/Clash/non_ip/direct.txt",
      interval: 43200,
      format: "text",
      proxy: proxyName,
      path: "./sukkaw_ruleset/direct_non_ip.txt"
    },
    domestic_ip: {
      type: "http",
      behavior: "classical",
      url: "https://ruleset.skk.moe/Clash/ip/domestic.txt",
      interval: 43200,
      format: "text",
      proxy: proxyName,
      path: "./sukkaw_ruleset/domestic_ip.txt"
    },

  };

  // China router
  const china_router_rules = {
    china_ip: {
      type: "http",
      behavior: "ipcidr",
      format: "text",
      interval: 43200,
      url: "https://ruleset.skk.moe/Clash/ip/china_ip.txt",
      proxy: proxyName,
      path: "./sukkaw_ruleset/china_ip.txt"
    },
    china_ip_ipv6: {
      type: "http",
      behavior: "ipcidr",
      format: "text",
      interval: 43200,
      url: "https://ruleset.skk.moe/Clash/ip/china_ip_ipv6.txt",
      proxy: proxyName,
      path: "./sukkaw_ruleset/china_ipv6.txt"
    }
  };

  // Global app
  const global_app_rules = {
    twitter: {
      type: "http",
      behavior: "domain",
      url: "https://github.com/666OS/YYDS/raw/main/mihomo/rules/twitter.mrs",
      interval: 86400,
      format: "mrs",
      proxy: proxyName,
      path: "./yyds/twitter.mrs",
    },
    instagram: {
      type: "http",
      behavior: "domain",
      url: "https://github.com/666OS/YYDS/raw/main/mihomo/rules/instagram.mrs",
      interval: 86400,
      format: "mrs",
      proxy: proxyName,
      path: "./yyds/instagram.mrs",
    },
    tiktok: {
      type: "http",
      behavior: "domain",
      url: "https://github.com/666OS/YYDS/raw/main/mihomo/rules/tiktok.mrs",
      interval: 86400,
      format: "mrs",
      proxy: proxyName,
      path: "./yyds/tiktok.mrs",
    },
    github: {
      type: "http",
      behavior: "domain",
      url: "https://github.com/666OS/YYDS/raw/main/mihomo/rules/github.mrs",
      interval: 86400,
      format: "mrs",
      proxy: proxyName,
      path: "./yyds/github.mrs",
    },
    facebook: {
      type: "http",
      behavior: "domain",
      url: "https://github.com/666OS/YYDS/raw/main/mihomo/rules/facebook.mrs",
      interval: 86400,
      format: "mrs",
      proxy: proxyName,
      path: "./yyds/facebook.mrs",
    },
    meta: {
      type: "http",
      behavior: "domain",
      url: "https://github.com/666OS/YYDS/raw/main/mihomo/rules/meta.mrs",
      interval: 86400,
      format: "mrs",
      proxy: proxyName,
      path: "./yyds/meta.mrs",
    },
    google: {
      type: "http",
      behavior: "domain",
      url: "https://github.com/666OS/YYDS/raw/main/mihomo/rules/google.mrs",
      interval: 86400,
      format: "mrs",
      proxy: proxyName,
      path: "./yyds/google.mrs",
    },
    "paypal@cn": {
      type: "http",
      behavior: "domain",
      url: "https://github.com/666OS/YYDS/raw/main/mihomo/rules/paypal@cn.mrs",
      interval: 86400,
      format: "mrs",
      proxy: proxyName,
      path: "./yyds/paypal@cn.mrs",
    },
    paypal: {
      type: "http",
      behavior: "domain",
      url: "https://github.com/666OS/YYDS/raw/main/mihomo/rules/paypal.mrs",
      interval: 86400,
      format: "mrs",
      proxy: proxyName,
      path: "./yyds/paypal.mrs",
    },
    "cloudflare-cn": {
      type: "http",
      behavior: "domain",
      url: "https://github.com/666OS/YYDS/raw/main/mihomo/rules/cloudflare-cn.mrs",
      interval: 86400,
      format: "mrs",
      proxy: proxyName,
      path: "./yyds/cloudflare-cn.mrs",
    },
    facebook_ip: {
      type: "http",
      behavior: "ipcidr",
      url: "https://github.com/666OS/YYDS/raw/main/mihomo/rules/facebook_ip.mrs",
      interval: 86400,
      format: "mrs",
      proxy: proxyName,
      path: "./yyds/facebook_ip.mrs",
    },
    google_ip: {
      type: "http",
      behavior: "ipcidr",
      url: "https://github.com/666OS/YYDS/raw/main/mihomo/rules/google_ip.mrs",
      interval: 86400,
      format: "mrs",
      proxy: proxyName,
      path: "./yyds/google_ip.mrs",
    },
    netflix_ip: {
      type: "http",
      behavior: "ipcidr",
      url: "https://github.com/666OS/YYDS/raw/main/mihomo/rules/netflix_ip.mrs",
      interval: 86400,
      format: "mrs",
      proxy: proxyName,
      path: "./yyds/netflix_ip.mrs",
    },
    twitter_ip: {
      type: "http",
      behavior: "ipcidr",
      url: "https://github.com/666OS/YYDS/raw/main/mihomo/rules/twitter_ip.mrs",
      interval: 86400,
      format: "mrs",
      proxy: proxyName,
      path: "./yyds/twitter_ip.mrs",
    },
  };

  // Combine all rules into a single object
  const rule_providers = {};
  Object.assign(
    rule_providers,
    reject_rules,
    speedtest_rules,
    cdn_rules,
    stream_rules,
    ai_rules,
    telegram_rules,
    apple_rules,
    microsoft_rules,
    download_rules,
    private_rules,
    misc_rules,
    china_router_rules,
    global_app_rules,
  );
  // Update rule_providers to use proxyName for all entries
  Object.keys(rule_providers).forEach((key) => {
    rule_providers[key].proxy = proxyName;
    rule_providers[key].interval = 43200;
  });
  return rule_providers;
}

function getRules() {
  // custom Rules
  const customRulesDict = {
    School: {
      rules: [
        "DOMAIN-KEYWORD,tju",
        "DOMAIN-KEYWORD,nju",
      ],
      action: "DIRECT",
    },
    Direct: {
      rules: [
        "IP-CIDR,23.106.156.223/8",
        "DOMAIN-KEYWORD,natpierce",
        "DOMAIN-KEYWORD,kaspersky",
        "DOMAIN-KEYWORD,hf-mirror",
        "DOMAIN,public.boxcloud.com",
        "DOMAIN-SUFFIX,aowu.tv",
        "DOMAIN,anime.girigirilove.com",
        // "DOMAIN,www.latexlive.com",
        // "DOMAIN-SUFFIX,latexlive.com",
      ],
      action: "DIRECT",
    },
    Safe: {
      rules: [
        "DOMAIN,imap-mail.outlook.com",
        "DOMAIN-KEYWORD,wandb",
        "DOMAIN,hostloc.com",
        "DOMAIN,challenges.cloudflare.com",
      ],
      action: "SafeProxy",
    },
    AIGC: {
      rules: [
        "DOMAIN,x.ai",
        "DOMAIN,grok.com",
        "DOMAIN,assets.grok.com",
      ],
      action: "AIGC",
    },
    Proxy: {
      rules: [
        "PROCESS-NAME,aria2c.exe",
        "DOMAIN,app.follow.is",
        "DOMAIN,openpanel.follow.is",
        "DOMAIN-KEYWORD,potpieai",
      ],
      action: proxyName,
    },
    ProxyDownload: {
      rules: [
        "DOMAIN,ghcr.io",
        "DOMAIN,cas-bridge-direct.xethub.hf.co",
        "DOMAIN,cas-bridge.xethub.hf.co"
      ],
      action: "ProxyDownload",
    },
  };
  const customRules = Object.values(customRulesDict).flatMap((group) =>
    group.rules.map((rule) => `${rule},${group.action}`)
  );

  // reject rules
  const adNonipRules = [
    "RULE-SET,reject_non_ip,REJECT",
    "RULE-SET,reject_domainset,REJECT",
    "RULE-SET,reject_non_ip_drop,REJECT-DROP",
    "RULE-SET,reject_non_ip_no_drop,REJECT",
    "RULE-SET,category-public-tracker,REJECT-DROP",
  ];
  const adipRules = [
    "RULE-SET,reject_ip,REJECT", // Reject IP addresses
  ];

  // cdn rules
  const cdnNonipRules = [
    // CDN rules for non-IP addresses
    "RULE-SET,cdn_domainset,CDN", // Use the proxy for CDN domain sets
    "RULE-SET,cdn_non_ip,CDN", // Use the proxy for non-IP CDN rules
  ];

  // speedtest rules
  const speedtestNonipRules = [
    "RULE-SET,speedtest," + proxyName,
  ];

  // stream rules
  const streamNonipRules = [
    // Stream rules for non-IP addresses
    "RULE-SET,youtube,Youtube",
    "RULE-SET,spotify,Spotify",
    "RULE-SET,netflix,Netflix",
    "RULE-SET,disney,Disney",
    "RULE-SET,stream_non_ip,Stream",
  ];
  const streamIpRules = [
    // Stream rules for IP addresses
    "RULE-SET,stream_ip,Stream", // Use the proxy for IP stream rules
  ];

  // ai
  const aiNonipRules = [
    // AI rules for non-IP addresses
    "RULE-SET,ai_non_ip,AIGC",
    "RULE-SET,openai,AIGC",
  ];

  // telegram rules
  const telegramNonipRules = [
    // Telegram rules for non-IP addresses
    "RULE-SET,telegram,Telegram", // Use Telegram for domain-based rules
    "RULE-SET,telegram_non_ip,Telegram", // Use Telegram for non-IP rules
  ];
  const telegramIpRules = [
    // Telegram rules for IP addresses
    "RULE-SET,telegram_ip,Telegram", // Use Telegram for IP-based rules
    // Note: This rule should be used to handle Telegram IP addresses
  ];

  // apple rules
  const appleNonipRules = [
    // Apple rules for non-IP addresses
    "RULE-SET,apple_cdn,CDN", // Use the proxy for Apple CDN domains
    "RULE-SET,apple_services,Apple", // Use the proxy for Apple services
    "RULE-SET,apple,Apple", // Use Apple for other Apple domains
    "RULE-SET,apple-cn,DIRECT", // Use DIRECT for apple-cn
    "RULE-SET,apple_cn_non_ip,DIRECT", // Use DIRECT for apple-cn non-IP
  ];

  // microsoft rules
  const microsoftNonipRules = [
    "RULE-SET,microsoft_cdn_non_ip,CDN", // Use the proxy for Microsoft CDN domains
    "RULE-SET,onedrive,OneDrive", // Use Microsoft for OneDrive
    "RULE-SET,microsoft_non_ip,Microsoft", // Use the proxy for non-IP Microsoft domains
    "RULE-SET,microsoft@cn,DIRECT", // Use DIRECT for microsoft@cn
    "RULE-SET,microsoft,Microsoft", // Use Microsoft for other Microsoft domains
  ];

  // download rules
  const downloadNonipRules = [
    // Download rules for non-IP addresses
    "RULE-SET,download_domainset,ProxyDownload", // Use the proxy for download domain sets
    "RULE-SET,download_non_ip,ProxyDownload", // Use the proxy for non-IP download rules
  ];

  // private rules
  const privateNonipRules = [
    // Private rules for non-IP addresses
    "RULE-SET,private_domain,DIRECT", // Use the proxy for private domains
    "RULE-SET,lan_non_ip,DIRECT", // Use DIRECT for LAN non-IP addresses
  ];
  const privateIpRules = [
    "RULE-SET,lan_ip,DIRECT", // Use DIRECT for LAN IP addresses
    "RULE-SET,private_ip,DIRECT", // Use DIRECT for private IP addresses
  ];

  // misc rules
  const miscNonipRules = [
    // Miscellaneous rules for non-IP addresses
    "RULE-SET,global_non_ip," + proxyName, // Use DIRECT for global non-IP addresses
    "RULE-SET,domestic_non_ip,DIRECT", // Use DIRECT for domestic non-IP addresses
    "RULE-SET,direct_non_ip,DIRECT", // Use DIRECT for direct non-IP addresses
  ];
  const miscIpRules = [
    "RULE-SET,domestic_ip,DIRECT", // Use DIRECT for domestic IP addresses
  ];

  // china router rules
  const chinaRouterIpRules = [
    // China router rules for non-IP addresses
    "RULE-SET,china_ip,DIRECT", // Use DIRECT for China IP addresses
    // "RULE-SET,china_ip_ipv6,DIRECT", // Use DIRECT for China IPv6 addresses
  ];

  // global app
  const globalAppNonipRules = [
    // Global app rules for non-IP addresses
    "RULE-SET,twitter,Twitter", 
    "RULE-SET,instagram,Instagram",
    "RULE-SET,tiktok,Tiktok",
    "RULE-SET,github," + proxyName, // Use the proxy for GitHub
    "RULE-SET,facebook,Meta", // Use Telegram for Facebook
    "RULE-SET,meta,Meta", // Use Telegram for Meta
    "RULE-SET,google,Google", // Use the proxy for Google
    "RULE-SET,paypal@cn,DIRECT", // Use DIRECT for paypal@cn
    "RULE-SET,paypal," + proxyName, // Use the proxy for PayPal
    "RULE-SET,cloudflare-cn,DIRECT", // Use DIRECT for cloudflare-cn
  ];
  const globalAppIpRules = [
    // Global app rules for IP addresses
    "RULE-SET,facebook_ip,Meta", // Use Telegram for Facebook IP
    "RULE-SET,google_ip,Google", // Use the proxy for Google IP
    "RULE-SET,netflix_ip,Netflix", // Use Netflix for Netflix IP
    "RULE-SET,twitter_ip,Twitter", // Use Telegram for Twitter IP
  ];

  const nonipRules = [
    ...adNonipRules,
    ...customRules,
    ...cdnNonipRules,
    ...speedtestNonipRules,
    ...downloadNonipRules,
    ...aiNonipRules,
    ...streamNonipRules,
    ...appleNonipRules,
    ...microsoftNonipRules,
    ...telegramNonipRules,
    ...globalAppNonipRules,
    ...miscNonipRules,
    ...privateNonipRules,
  ];

  const ipRules = [
    ...adipRules,
    ...streamIpRules,
    ...telegramIpRules,
    ...globalAppIpRules,
    ...miscIpRules,
    ...chinaRouterIpRules,
    ...privateIpRules,
  ];

  const rules = [
    // 非ip类规则
    ...nonipRules,
    // "DOMAIN-REGEX,^[a-zA-Z0-9-]+(.[a-zA-Z0-9-]+)+$,Others",
    // ip类规则
    ...ipRules,
    "MATCH,Others",
  ];

  return rules;
}


// Overwrite Rules
function overwriteRules(params) {
  const rule_providers = getRuleProviders();
  const rules = getRules();

  params["rule-providers"] = rule_providers;
  params["rules"] = rules;
}
// Overwrite Other Rules by Rule Providers
function updateOtherRulesByRuleProviders(params) {
  // 默认配置
  const skipRuleProviders = ["domestic_non_ip", "direct_non_ip", "lan_non_ip", "private_domain"];
  
  // 获取params中实际存在的规则提供者
  const availableProviders = [];
  for (const provider of skipRuleProviders) {
    if (provider in params["rule-providers"]) {
      availableProviders.push(provider);
    }
  }
  
  // 如果没有可用的规则提供者，则直接返回
  if (availableProviders.length === 0) {
    return;
  }
  
  // 构建规则集引用字符串
  const ruleSetRef = `rule-set:${availableProviders.join(',')}`;
  
  // 更新sniffer.skip-domain配置
  params["sniffer"]["skip-domain"] = [
    ruleSetRef,
    ...params["sniffer"]["skip-domain"]
  ];
  // 更新dns.fake-ip-filter配置
  params["dns"]["fake-ip-filter"] = [
    ruleSetRef,
    ...params["dns"]["fake-ip-filter"]
  ];
}

function overwtiteRulesOptions(params) {
  overwriteRules(params); // Overwrite rules and rule providers
  updateOtherRulesByRuleProviders(params); // Update other rules based on rule providers
}

// ==============================================================================
// ===============PROXY Options===============================
// ==============================================================================
// Overwrite ProxyyProviders
function overwriteProxyProviders(params) {
  // 如果没有 proxy-providers 属性，直接返回
  if (!params["proxy-providers"]) return;
  
  // 默认配置，将应用于所有代理提供者
  const defaultConfig = {
    interval: 3600,          // 更新间隔（秒）
    proxy: proxyName,        // 使用脚本中定义的代理名称
    "size-limit": 0,         // 无大小限制
    header: {
      "User-Agent": ["mihomo/1.18.3"]
    },
    "health-check": {
      enable: true,
      lazy: true,            // 延迟启动健康检查
      url: "https://cp.cloudflare.com",
      interval: 300,         // 健康检查间隔（秒）
      timeout: 5000,         // 超时时间（毫秒）
      "expected-status": 204 // 期望的HTTP状态码
    }
  };
  
  // 遍历所有代理提供者并应用配置
  for (const providerName in params["proxy-providers"]) {
    const provider = params["proxy-providers"][providerName];
    
    // 保留原URL和路径
    const url = provider.url;
    const path = provider.path;
    
    // 保留override设置如果存在
    const override = provider.override || {};
    
    // 应用默认配置，但保留原有的URL和路径
    Object.assign(provider, defaultConfig, { url, path, override });
  }
}
// Overwrite Proxy Groups
function overwriteProxyGroups(params) {
  // All proxy
  const allProxies = params["proxies"].map((e) => e.name);
  const allProxyProviders = Object.keys(
    params["rule-providers"] || {}
  );

  // 公共的正则片段
  const excludeTerms =
    "剩余|到期|主页|官网|游戏|关注|网站|地址|有效|网址|禁止|邮箱|发布|客服|订阅|节点|问题|联系";
  // 包含条件：各个国家或地区的关键词
  const includeTerms = {
    HK: "(香港|HK|Hong|🇭🇰)",
    TW: "(台湾|TW|Taiwan|Wan|🇹🇼|🇨🇳)",
    SG: "(新加坡|狮城|SG|Singapore|🇸🇬)",
    JP: "(日本|JP|Japan|🇯🇵)",
    KR: "(韩国|韓|KR|Korea|🇰🇷)",
    US: "(美国|US|United States|America|🇺🇸)",
    UK: "(英国|UK|United Kingdom|🇬🇧)",
    FR: "(法国|FR|France|🇫🇷)",
    DE: "(德国|DE|Germany|🇩🇪)",
    MQ: "(mq)",
    PC: "(ProxyChain)",
  };
  // 合并所有国家关键词，供"Others"条件使用
  const allCountryTerms = Object.values(includeTerms).join("|");
  // 自动代理组正则表达式配置
  const autoProxyGroupRegexs = [
    {
      name: "HK - Auto",
      filter: `^(?=.*${includeTerms.HK})(?!.*${excludeTerms}).*$`, // 正则表达式，匹配包含HK的条目
    },
    {
      name: "TW - Auto",
      filter: `^(?=.*${includeTerms.TW})(?!.*${excludeTerms}).*$`, // 正则表达式，匹配包含TW的条目
    },
    {
      name: "SG - Auto",
      filter: `^(?=.*${includeTerms.SG})(?!.*${excludeTerms}).*$`,
    },
    {
      name: "JP - Auto",
      filter: `^(?=.*${includeTerms.JP})(?!.*${excludeTerms}).*$`,
    },
    {
      name: "KR - Auto",
      filter: `^(?=.*${includeTerms.KR})(?!.*${excludeTerms}).*$`,
    },
    {
      name: "US - Auto",
      filter: `^(?=.*${includeTerms.US})(?!.*${excludeTerms}).*$`,
    },
    {
      name: "UK - Auto",
      filter: `^(?=.*${includeTerms.UK})(?!.*${excludeTerms}).*$`,
    },
    {
      name: "FR - Auto",
      filter: `^(?=.*${includeTerms.FR})(?!.*${excludeTerms}).*$`,
    },
    {
      name: "DE - Auto",
      filter: `^(?=.*${includeTerms.DE})(?!.*${excludeTerms}).*$`,
    },
    {
      name: "MQ - Auto",
      filter: `^(?=.*${includeTerms.MQ})(?!.*${excludeTerms}).*$`,
    },
    {
      name: "ProxyChain - Auto",
      filter: `^(?=.*${includeTerms.PC})(?!.*${excludeTerms}).*$`,
    },
    {
      name: "Others - Auto",
      filter: `^(?!.*(?:${allCountryTerms}|${excludeTerms})).*$`,
    },
  ];
  // Auto
  const autoProxyGroups = autoProxyGroupRegexs
    .map((item) => ({
      name: item.name,
      type: "url-test",
      url: "https://cp.cloudflare.com",
      interval: 300,
      tolerance: 50,
      "disable-udp": false,
      "include-all": true, // Include all options in the dropdown
      filter: item.filter,
      // "exclude-filter": excludeTerms.replace(/\|/g, "`"),
      hidden: true,
    }));
  // LB Hash
  const loadBalanceHashGroups = autoProxyGroupRegexs
  .map((item) => {
    const regionCode = item.name.split(' - ')[0];
    
    let groupName = `${regionCode} - LB Hash`; // 例如: HK - LB Hash
    
    return {
      name: groupName,
      type: "load-balance",
      url: "https://cp.cloudflare.com",
      interval: 300,
      "max-failed-times": 3,
      strategy: "consistent-hashing",
      lazy: true, 
      "include-all": true, 
      filter: item.filter,
      hidden: true,
    };
  });
  // LB Polling
  const loadBalancePollingGroups = autoProxyGroupRegexs
  .map((item) => {
    const regionCode = item.name.split(' - ')[0];
    
    let groupName = `${regionCode} - LB Polling`; // 例如: HK - LB Polling
    
    return {
      name: groupName,
      type: "load-balance",
      url: "https://cp.cloudflare.com",
      interval: 300,
      "max-failed-times": 3,
      strategy: "round-robin",
      lazy: true, 
      "include-all": true, 
      filter: item.filter,
      hidden: true,
    };
  });

  

  // Select代理组
  const manualProxyGroups = [
    {
      name: "HK - Select",
      filter: `^(?=.*${includeTerms.HK})(?!.*${excludeTerms}).*$`,
      icon: "https://fastly.jsdelivr.net/gh/clash-verge-rev/clash-verge-rev.github.io@main/docs/assets/icons/flags/hk.svg",
    },
    {
      name: "JP - Select",
      filter: `^(?=.*${includeTerms.JP})(?!.*${excludeTerms}).*$`,
      icon: "https://fastly.jsdelivr.net/gh/clash-verge-rev/clash-verge-rev.github.io@main/docs/assets/icons/flags/jp.svg",
    },
    {
      name: "KR - Select",
      filter: `^(?=.*${includeTerms.KR})(?!.*${excludeTerms}).*$`,
      icon: "https://fastly.jsdelivr.net/gh/clash-verge-rev/clash-verge-rev.github.io@main/docs/assets/icons/flags/kr.svg",
    },
    {
      name: "SG - Select",
      filter: `^(?=.*${includeTerms.SG})(?!.*${excludeTerms}).*$`,
      icon: "https://fastly.jsdelivr.net/gh/clash-verge-rev/clash-verge-rev.github.io@main/docs/assets/icons/flags/sg.svg",
    },
    {
      name: "US - Select",
      filter: `^(?=.*${includeTerms.US})(?!.*${excludeTerms}).*$`,
      icon: "https://fastly.jsdelivr.net/gh/clash-verge-rev/clash-verge-rev.github.io@main/docs/assets/icons/flags/us.svg",
    },
    {
      name: "UK - Select",
      filter: `^(?=.*${includeTerms.UK})(?!.*${excludeTerms}).*$`,
      icon: "https://fastly.jsdelivr.net/gh/clash-verge-rev/clash-verge-rev.github.io@main/docs/assets/icons/flags/gb.svg",
    },
    {
      name: "FR - Select",
      filter: `^(?=.*${includeTerms.FR})(?!.*${excludeTerms}).*$`,
      icon: "https://fastly.jsdelivr.net/gh/clash-verge-rev/clash-verge-rev.github.io@main/docs/assets/icons/flags/fr.svg",
    },
    {
      name: "DE - Select",
      filter: `^(?=.*${includeTerms.DE})(?!.*${excludeTerms}).*$`,
      icon: "https://fastly.jsdelivr.net/gh/clash-verge-rev/clash-verge-rev.github.io@main/docs/assets/icons/flags/de.svg",
    },
    {
      name: "TW - Select",
      filter: `^(?=.*${includeTerms.TW})(?!.*${excludeTerms}).*$`,
      icon: "https://fastly.jsdelivr.net/gh/clash-verge-rev/clash-verge-rev.github.io@main/docs/assets/icons/flags/tw.svg",
    },
    {
      name: "MQ - Select",
      filter: `^(?=.*${includeTerms.MQ})(?!.*${excludeTerms}).*$`,
      icon: "https://fastly.jsdelivr.net/gh/clash-verge-rev/clash-verge-rev.github.io@main/docs/assets/icons/speed.svg",
    },
    {
      name: "ProxyChain - Select",
      filter: `^(?=.*${includeTerms.PC})(?!.*${excludeTerms}).*$`,
      icon: "https://fastly.jsdelivr.net/gh/clash-verge-rev/clash-verge-rev.github.io@main/docs/assets/icons/guard.svg",
    },
    {
      name: "Others - Select",
      filter: `^(?!.*(?:${allCountryTerms}|${excludeTerms})).*$`,
      icon: "https://fastly.jsdelivr.net/gh/clash-verge-rev/clash-verge-rev.github.io@main/docs/assets/icons/ambulance.svg",
    },
  ];

  const manualProxyGroupsConfig = manualProxyGroups
    .map((item) => ({
      name: item.name,
      type: "select",
      url: "https://cp.cloudflare.com",
      "disable-udp": false,
      "include-all": true,
      filter: item.filter,
      icon: item.icon,
      hidden: false,
    }));

  const proxy_groups_proxies_base = [proxyName, "DIRECT", "Auto", "Select", "LB Hash", "LB Polling"]
  // 从 manualProxyGroups 中提取所有 name
  const manualGroupNames = manualProxyGroups.map(group => group.name);

  // 从 autoProxyGroups 中提取所有 name
  const autoGroupNames = autoProxyGroups.map(group => group.name);

  // 从 loadBalanceHashGroups 中提取所有 name
  const loadBalanceHashGroupNames = loadBalanceHashGroups.map(group => group.name);

  // 从 loadBalancePollingGroups 中提取所有 name
  const loadBalancePollingGroupNames = loadBalancePollingGroups.map(group => group.name);

  // 将提取的名称添加到 proxy_groups_proxies_base 数组
  proxy_groups_proxies_base.push(...autoGroupNames, ...manualGroupNames, ...loadBalanceHashGroupNames, ...loadBalancePollingGroupNames);

  const groups = [
    {
      name: proxyName,
      type: "select",
      url: "https://cp.cloudflare.com",
      icon: "https://fastly.jsdelivr.net/gh/clash-verge-rev/clash-verge-rev.github.io@main/docs/assets/icons/adjust.svg",
      proxies: [
        "Auto",
        "Select",
        "LB Hash",
        "LB Polling",
        "DIRECT",
      ],
    },
    {
      name: "Select",
      type: "select",
      url: "https://cp.cloudflare.com",
      icon: "https://fastly.jsdelivr.net/gh/clash-verge-rev/clash-verge-rev.github.io@main/docs/assets/icons/link.svg",
      "include-all": true, // Include all options in the dropdown
    },
    {
      name: "Auto",
      type: "select",
      url: "https://cp.cloudflare.com",
      icon: "https://fastly.jsdelivr.net/gh/clash-verge-rev/clash-verge-rev.github.io@main/docs/assets/icons/speed.svg",
      proxies: ["ALL - Auto"].concat(autoGroupNames),
    },
    {
      name: "LB Hash",
      type: "select",
      url: "https://cp.cloudflare.com",
      icon: "https://fastly.jsdelivr.net/gh/clash-verge-rev/clash-verge-rev.github.io@main/docs/assets/icons/balance.svg",
      proxies: ["ALL - LB Hash"].concat(loadBalanceHashGroupNames), 
    },
    {
      name: "LB Polling",
      type: "select",
      url: "https://cp.cloudflare.com",
      icon: "https://fastly.jsdelivr.net/gh/clash-verge-rev/clash-verge-rev.github.io@main/docs/assets/icons/merry_go.svg",
      proxies: ["ALL - LB Polling"].concat(loadBalancePollingGroupNames), 
    },
    {
      name: "ALL - LB Hash",
      type: "load-balance",
      url: "https://cp.cloudflare.com",
      icon: "https://fastly.jsdelivr.net/gh/clash-verge-rev/clash-verge-rev.github.io@main/docs/assets/icons/balance.svg",
      "include-all": true, // Include all options in the dropdown
      interval: 300,
      "max-failed-times": 3,
      strategy: "consistent-hashing",
      lazy: true,
      hidden: true,
    },
    {
      name: "ALL - LB Polling",
      type: "load-balance",
      url: "https://cp.cloudflare.com",
      icon: "https://fastly.jsdelivr.net/gh/clash-verge-rev/clash-verge-rev.github.io@main/docs/assets/icons/merry_go.svg",
      "include-all": true, // Include all options in the dropdown
      interval: 300,
      "max-failed-times": 3,
      strategy: "round-robin",
      lazy: true,
      proxies: allProxies,
      hidden: true,
    },
    {
      name: "ALL - Auto",
      type: "url-test",
      url: "https://cp.cloudflare.com",
      interval: 300,
      tolerance: 50,
      "include-all": true, // Include all options in the dropdown
      hidden: true,
    },
    {
      name: "ProxyDownload",
      type: "select",
      proxies: proxy_groups_proxies_base,
      "include-all": true,
      icon: svgToDataUri(downloadSvgCode),
    },
    {
      name: "SafeProxy",
      type: "select",
      proxies: proxy_groups_proxies_base,
      "include-all": true,
      icon: svgToDataUri(safetySvgCode),
    },
    {
      name: "CDN",
      type: "select",
      proxies: proxy_groups_proxies_base,
      icon: "https://raw.githubusercontent.com/Orz-3/mini/master/Color/Skicat.png"
    },
    {
      name: "Stream",
      type: "select",
      proxies: proxy_groups_proxies_base,
      icon: "https://raw.githubusercontent.com/Koolson/Qure/master/IconSet/Color/LineTV.png", // Use a generic streaming icon
    },
    {
      name: "AIGC",
      type: "select",
      proxies: proxy_groups_proxies_base,
      "include-all": true,
      icon: "https://fastly.jsdelivr.net/gh/clash-verge-rev/clash-verge-rev.github.io@main/docs/assets/icons/chatgpt.svg",
    },
    {
      name: "Apple",
      type: "select",
      proxies: proxy_groups_proxies_base,
      "include-all": true,
      icon: "https://fastly.jsdelivr.net/gh/clash-verge-rev/clash-verge-rev.github.io@main/docs/assets/icons/apple.svg",
    },
    {
      name: "Google",
      type: "select",
      proxies: proxy_groups_proxies_base,
      "include-all": true, // Include all options in the dropdown
      icon: "https://fastly.jsdelivr.net/gh/clash-verge-rev/clash-verge-rev.github.io@main/docs/assets/icons/google.svg",
    },
    {
      name: "Microsoft",
      type: "select",
      proxies: proxy_groups_proxies_base,
      "include-all": true,
      icon: "https://fastly.jsdelivr.net/gh/clash-verge-rev/clash-verge-rev.github.io@main/docs/assets/icons/microsoft.svg",
    },
    {
      name: "OneDrive",
      type: "select",
      proxies: proxy_groups_proxies_base,
      "include-all": true,
      icon: "https://fastly.jsdelivr.net/gh/clash-verge-rev/clash-verge-rev.github.io@main/docs/assets/icons/onedrive.svg",
    },
    {
      name: "Youtube",
      type: "select",
      proxies: proxy_groups_proxies_base,
      "include-all": true,
      icon: "https://fastly.jsdelivr.net/gh/clash-verge-rev/clash-verge-rev.github.io@main/docs/assets/icons/youtube.svg"
    },
    {
      name: "Telegram",
      type: "select",
      proxies: proxy_groups_proxies_base,
      "include-all": true,
      icon: "https://fastly.jsdelivr.net/gh/clash-verge-rev/clash-verge-rev.github.io@main/docs/assets/icons/telegram.svg",
    },
    {
      name: "Spotify",
      type: "select",
      proxies: proxy_groups_proxies_base,
      "include-all": true,
      icon: "https://storage.googleapis.com/spotifynewsroom-jp.appspot.com/1/2020/12/Spotify_Icon_CMYK_Green.png",
    },
    {
      name: "Netflix",
      type: "select",
      proxies: proxy_groups_proxies_base,
      "include-all": true,
      icon: "https://fastly.jsdelivr.net/gh/clash-verge-rev/clash-verge-rev.github.io@main/docs/assets/icons/netflix.svg",
    },
    {
      name: "Disney",
      type: "select",
      proxies: proxy_groups_proxies_base,
      "include-all": true,
      icon: "https://fastly.jsdelivr.net/gh/clash-verge-rev/clash-verge-rev.github.io@main/docs/assets/icons/disney_plus.svg",
    },  
    {
      name: "Meta",
      type: "select",
      proxies: proxy_groups_proxies_base,
      "include-all": true, // Include all options in the dropdown
      icon: "https://fastly.jsdelivr.net/gh/clash-verge-rev/clash-verge-rev.github.io@main/docs/assets/icons/facebook.svg",
    },
    {
      name: "Twitter",
      type: "select",
      proxies: proxy_groups_proxies_base,
      "include-all": true, // Include all options in the dropdown
      icon: "https://fastly.jsdelivr.net/gh/clash-verge-rev/clash-verge-rev.github.io@main/docs/assets/icons/twitter.svg",
    },
    {
      name: "Instagram",
      type: "select",
      proxies: proxy_groups_proxies_base,
      "include-all": true, // Include all options in the dropdown
      icon: "https://fastly.jsdelivr.net/gh/clash-verge-rev/clash-verge-rev.github.io@main/docs/assets/icons/instagram.svg",
    },
    {
      name: "Tiktok", 
      type: "select",
      proxies: proxy_groups_proxies_base,
      "include-all": true, // Include all options in the dropdown
      icon: "https://fastly.jsdelivr.net/gh/clash-verge-rev/clash-verge-rev.github.io@main/docs/assets/icons/tiktok.svg",
    },
    {
      name: "Others",
      type: "select",
      proxies: ["DIRECT", proxyName],
      icon: "https://fastly.jsdelivr.net/gh/clash-verge-rev/clash-verge-rev.github.io@main/docs/assets/icons/fish.svg",
    },
  ];

  groups.push(...autoProxyGroups);
  groups.push(...manualProxyGroupsConfig);
  groups.push(...loadBalanceHashGroups);
  groups.push(...loadBalancePollingGroups);
  params["proxy-groups"] = groups;
}

function overwriteProxyOptions(params) {
  overwriteProxyProviders(params); // Overwrite proxy providers
  overwriteProxyGroups(params); // Overwrite proxy groups
}
// ==============================================================================
// ==============================================================================
// ==============================================================================

// ==============================================================================
// ================ 配置函数 ================
// ==============================================================================

function svgToDataUri(svgCode) {
  return `data:image/svg+xml,${encodeURIComponent(svgCode)}`;
}

const downloadSvgCode = `<svg t="1735825580241" class="icon" viewBox="0 0 1024 1024" version="1.1" xmlns="http://www.w3.org/2000/svg" p-id="1521" width="200" height="200"><path d="M537 137c165.23 0 302.183 121.067 326.991 279.332C922.626 464.753 960 538.012 960 620c0 145.803-118.197 264-264 264H348c-156.942-0.542-284-127.933-284-285 0-115.73 68.98-215.348 168.067-259.984C282.35 220.296 399.947 137 537 137z m-25 255c-17.673 0-32 14.327-32 32v175.758l-45.373-45.383-0.377-0.372c-12.524-12.127-32.506-12.003-44.877 0.372-12.497 12.5-12.497 32.765 0 45.265l84.52 84.54 0.635 0.624c21.06 20.395 54.635 20.27 75.543-0.434l85.444-84.618 0.373-0.375c12.186-12.467 12.162-32.453-0.148-44.89-12.435-12.561-32.696-12.662-45.255-0.225L544 600.296V424c0-17.673-14.327-32-32-32z" fill="#6495ED" p-id="1522"></path></svg>`;
const safetySvgCode = `<svg t="1735825766633" class="icon" viewBox="0 0 1024 1024" version="1.1" xmlns="http://www.w3.org/2000/svg" p-id="3573" width="200" height="200"><path d="M512 1024c-158.72 0-460.8-230.4-460.8-445.44V148.48h46.08s102.4 0 209.92-40.96C414.72 66.56 486.4 20.48 486.4 20.48s20.48-20.48 25.6-20.48c10.24 0 25.6 20.48 25.6 20.48s71.68 46.08 179.2 87.04c107.52 40.96 209.92 40.96 209.92 40.96h46.08v430.08c0 215.04-302.08 445.44-460.8 445.44z m-25.6-281.6l296.96-317.44-71.68-56.32-235.52 256-122.88-97.28-61.44 66.56 194.56 148.48z" fill="#1296db" p-id="3574"></path></svg>`;
const globalSvgCode = `<svg t="1735825974582" class="icon" viewBox="0 0 1024 1024" version="1.1" xmlns="http://www.w3.org/2000/svg" p-id="13638" width="200" height="200"><path d="M854.4 800.896l0.64-0.896A445.824 445.824 0 0 0 960 512a446.272 446.272 0 0 0-104.768-288l-0.704-0.832-3.2-3.648-1.28-1.408-4.032-4.736-0.128-0.064-4.608-5.12-0.064-0.064c-3.2-3.456-6.4-6.848-9.728-10.112l-0.064-0.128-4.8-4.8-0.32-0.256-4.48-4.352-1.6-1.472-3.008-2.816-1.024-1.024A445.824 445.824 0 0 0 512 64a446.272 446.272 0 0 0-304.32 119.168l-0.96 1.024-3.008 2.88-1.6 1.536-4.48 4.288-0.32 0.32-4.8 4.8-0.128 0.064-9.664 10.112-0.128 0.128a211.776 211.776 0 0 0-4.608 5.12H177.92a91.904 91.904 0 0 0-4.096 4.736l-1.28 1.408c-1.024 1.216-2.048 2.56-3.2 3.712-0.128 0.32-0.448 0.512-0.64 0.832A446.272 446.272 0 0 0 64 512c0 109.696 39.424 210.112 104.832 288l0.64 0.896 3.136 3.712 1.216 1.408 4.096 4.672 0.064 0.192c1.536 1.728 3.008 3.392 4.608 4.992l0.128 0.128 9.6 10.112 0.064 0.064 4.736 4.736 0.256 0.32A447.168 447.168 0 0 0 512 960a446.272 446.272 0 0 0 314.24-128.768l0.384-0.32c1.6-1.6 3.2-3.136 4.672-4.736l0.128-0.064a302.72 302.72 0 0 0 9.6-10.112l0.064-0.128c1.536-1.664 3.136-3.264 4.608-4.992 0-0.064 0.128-0.064 0.128-0.192 1.408-1.472 2.752-3.072 4.096-4.672l1.152-1.408c1.28-1.28 2.304-2.56 3.328-3.712z m4.096-142.592c-13.824 32.64-32 62.784-54.208 90.24a444.096 444.096 0 0 0-81.472-55.936c11.584-46.912 18.752-98.432 20.672-152.576h143.488a373.888 373.888 0 0 1-28.48 118.272z m28.48-174.272h-143.488a747.584 747.584 0 0 0-20.672-152.64 444.096 444.096 0 0 0 81.472-55.872 373.888 373.888 0 0 1 82.688 208.512z m-228.672-318.528a373.76 373.76 0 0 1 107.584 69.184c-18.496 15.808-38.4 29.696-59.392 41.792-15.68-44.992-35.84-84.096-59.2-115.392 3.712 1.408 7.424 2.944 11.008 4.416zM567.68 866.112a113.152 113.152 0 0 1-27.648 16.384v-185.472a389.12 389.12 0 0 1 115.648 26.176c-8.32 24.576-17.92 47.36-28.992 67.84-17.408 32.384-37.76 58.24-59.008 75.072z m59.008-633.088c11.008 20.544 20.736 43.264 28.992 67.776a389.12 389.12 0 0 1-115.648 26.24V141.504c9.152 3.712 18.496 9.152 27.648 16.448 21.248 16.64 41.6 42.56 59.008 75.008z m-86.656 407.872V540.032h147.456c-1.6 44.16-7.04 87.04-16.32 127.744l-0.256 1.28a444.992 444.992 0 0 0-130.944-28.16z m0-156.864V383.104a444.992 444.992 0 0 0 130.88-28.16l0.32 1.28c9.152 40.704 14.72 83.456 16.256 127.808H539.968z m-56.064 56v100.864a444.992 444.992 0 0 0-130.88 28.16l-0.32-1.28a693.44 693.44 0 0 1-16.256-127.744h147.456z m-147.456-56.064c1.6-44.16 7.04-87.04 16.32-127.744l0.256-1.28a444.352 444.352 0 0 0 130.88 28.16v100.928H336.512z m147.456 213.056v185.344a111.872 111.872 0 0 1-27.648-16.384c-21.248-16.64-41.728-42.688-59.136-75.072a451.84 451.84 0 0 1-28.992-67.84 390.272 390.272 0 0 1 115.84-26.048z m0-370.048A389.12 389.12 0 0 1 368.32 300.8c8.32-24.576 17.92-47.36 28.992-67.84 17.408-32.384 37.76-58.368 59.072-75.072 9.216-7.168 18.432-12.672 27.712-16.384v185.472h-0.128zM365.76 165.504c3.712-1.472 7.296-3.008 11.008-4.416-23.424 31.36-43.52 70.4-59.2 115.392a387.648 387.648 0 0 1-59.392-41.792 373.76 373.76 0 0 1 107.584-69.184zM165.504 365.696c13.824-32.64 32-62.784 54.208-90.24 24.896 21.568 52.16 40.32 81.472 55.936a747.584 747.584 0 0 0-20.672 152.64H136.96c2.944-40.96 12.544-80.64 28.48-118.336zM136.96 539.968h143.488c1.92 54.208 9.088 105.728 20.672 152.64a444.096 444.096 0 0 0-81.472 55.872A373.888 373.888 0 0 1 136.96 539.968z m228.672 318.528a373.76 373.76 0 0 1-107.584-69.184c18.496-15.808 38.4-29.696 59.392-41.792 15.68 44.992 35.84 84.096 59.2 115.392a359.936 359.936 0 0 1-11.008-4.416z m292.608 0c-3.712 1.536-7.296 3.008-11.008 4.416 23.424-31.36 43.52-70.4 59.2-115.392 20.992 11.968 40.96 25.984 59.392 41.792a373.76 373.76 0 0 1-107.584 69.184z" fill="#96999C" p-id="13639"></path></svg>`;


