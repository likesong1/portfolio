# 송재혁 · Engineering Portfolio

5G 통신 검증과 문제 해결 경험을 정리한 개인 포트폴리오입니다.

썬더소프트코리아 재직 중 수행한 5G 품질 검증, Shannon DM 로그 분석·이슈 재현, CMD 자동화와 환경 표준화를 중심으로 소개합니다. IP·라우팅·스위칭과 SD-WAN 개념은 학습 노트로 구분하고, 별도로 만든 PowerShell 점검 도구를 공개 예제로 제공합니다.

## 보기

`index.html`을 브라우저에서 열면 됩니다. 외부 패키지 설치와 빌드가 필요하지 않습니다.

## 파일

- `index.html`: 블로그 홈, 검색, 분야별 글 필터, 경력 소개
- `posts/`: 실무·학습·예제 글 6편, 이전 경험 기록과 목차
- `tools/network-healthcheck.ps1`: 단일 대상의 주소 해석·ICMP·TCP 연결 점검 예제
- `.nojekyll`: GitHub Pages 정적 파일 게시 설정

## 점검 도구

PowerShell에서 `./tools/network-healthcheck.ps1`을 실행합니다. 기본 대상은 `127.0.0.1`입니다. TCP 연결은 `-TcpPort`를 지정했을 때만 확인합니다. 주소 해석·ICMP·TCP 연결 결과를 단계별로 기록하고 JSON으로 출력합니다.
